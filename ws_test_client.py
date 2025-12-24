#!/usr/bin/env python3
"""
WebSocket Test Client for provana.mafiola.net:5000

Usage:
    python3 ws_test_client.py                    # Interactive mode
    python3 ws_test_client.py --test-all         # Test all endpoints
    python3 ws_test_client.py --message '...'    # Send custom message
"""

import socket
import base64
import struct
import time
import json
import sys
import argparse

WS_HOST = "provana.mafiola.net"
WS_PORT = 5000

class WebSocketClient:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.sock = None
    
    def create_handshake(self, path="/"):
        key = base64.b64encode(b"testtesttesttest").decode()
        handshake = (
            f"GET {path} HTTP/1.1\r\n"
            f"Host: {self.host}:{self.port}\r\n"
            f"Upgrade: websocket\r\n"
            f"Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            f"Sec-WebSocket-Version: 13\r\n"
            f"\r\n"
        )
        return handshake.encode()
    
    def connect(self):
        """Establish WebSocket connection"""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.settimeout(5)
            self.sock.connect((self.host, self.port))
            self.sock.send(self.create_handshake())
            
            response = self.sock.recv(4096).decode()
            if "101" in response and "Upgrade" in response:
                print(f"✓ Connected to ws://{self.host}:{self.port}\n")
                return True
            else:
                print(f"❌ Failed to upgrade to WebSocket")
                return False
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return False
    
    def send_frame(self, message):
        """Send a WebSocket text frame"""
        if not self.sock:
            return False
        
        msg_bytes = message.encode() if isinstance(message, str) else message
        frame = bytearray([0x81])  # FIN=1, opcode=1 (text)
        length = len(msg_bytes)
        
        if length < 126:
            frame.append(0x80 | length)  # mask=1
        else:
            frame.append(0x80 | 126)
            frame.extend(struct.pack('>H', length))
        
        mask = b'\x00\x00\x00\x00'
        frame.extend(mask)
        frame.extend(msg_bytes)
        
        try:
            self.sock.send(frame)
            return True
        except Exception as e:
            print(f"❌ Send error: {e}")
            return False
    
    def receive_frame(self, timeout=2):
        """Receive and decode a WebSocket frame"""
        if not self.sock:
            return None
        
        try:
            self.sock.settimeout(timeout)
            data = self.sock.recv(4096)
            
            if len(data) < 2:
                return None
            
            payload_len = data[1] & 0x7F
            offset = 2
            
            if payload_len == 126:
                payload_len = struct.unpack('>H', data[2:4])[0]
                offset = 4
            elif payload_len == 127:
                payload_len = struct.unpack('>Q', data[2:10])[0]
                offset = 10
            
            if len(data) < offset + payload_len:
                return None
            
            return data[offset:offset+payload_len].decode('utf-8', errors='ignore')
        except socket.timeout:
            return None
        except Exception as e:
            print(f"❌ Receive error: {e}")
            return None
    
    def send_and_receive(self, payload, name=""):
        """Send a message and wait for response"""
        msg = json.dumps(payload) if isinstance(payload, dict) else payload
        
        print(f"📤 {name if name else 'Sending'}")
        print(f"   {msg}")
        
        if not self.send_frame(msg):
            return None
        
        time.sleep(0.5)
        response = self.receive_frame()
        
        if response:
            print(f"📥 Response:")
            try:
                parsed = json.loads(response)
                print(f"   {json.dumps(parsed, indent=2)}")
            except:
                print(f"   {response}")
        else:
            print(f"📥 No response (timeout)")
        
        print("-" * 60)
        return response
    
    def close(self):
        """Close WebSocket connection"""
        if self.sock:
            try:
                self.sock.close()
                print("\n✓ Connection closed")
            except:
                pass

def test_all_endpoints():
    """Test all documented endpoints"""
    client = WebSocketClient(WS_HOST, WS_PORT)
    
    if not client.connect():
        return
    
    print("=" * 60)
    print("TESTING ALL ENDPOINTS")
    print("=" * 60 + "\n")
    
    # Test 1: Onboarding Chat
    client.send_and_receive({
        "type": "ONBOARDING_CHAT",
        "message": "Hi agent"
    }, "Test 1: ONBOARDING_CHAT")
    
    # Test 2: Auth Check
    client.send_and_receive({
        "type": "AUTH",
        "action": "AUTH_CHECK"
    }, "Test 2: AUTH_CHECK")
    
    # Test 3: Auth Sign In
    client.send_and_receive({
        "type": "AUTH",
        "action": "SIGN_IN",
        "data": {
            "token": "test_token_12345"
        }
    }, "Test 3: AUTH - SIGN_IN")
    
    # Test 4: Notifications Subscribe
    client.send_and_receive({
        "type": "NOTIFICATIONS",
        "action": "SUBSCRIBE"
    }, "Test 4: NOTIFICATIONS - SUBSCRIBE")
    
    client.close()

def interactive_mode():
    """Interactive WebSocket client"""
    client = WebSocketClient(WS_HOST, WS_PORT)
    
    if not client.connect():
        return
    
    print("=" * 60)
    print("INTERACTIVE MODE")
    print("=" * 60)
    print("\nAvailable endpoints:")
    print("  1. ONBOARDING_CHAT")
    print("  2. AUTH (AUTH_CHECK, SIGN_IN)")
    print("  3. NOTIFICATIONS (SUBSCRIBE)")
    print("  4. Custom JSON message")
    print("  q. Quit\n")
    
    while True:
        try:
            choice = input("Select option (1-4, q): ").strip()
            
            if choice == 'q':
                break
            elif choice == '1':
                message = input("Enter message: ").strip()
                client.send_and_receive({
                    "type": "ONBOARDING_CHAT",
                    "message": message
                })
            elif choice == '2':
                action = input("Action (AUTH_CHECK/SIGN_IN): ").strip()
                payload = {"type": "AUTH", "action": action}
                if action == "SIGN_IN":
                    token = input("Enter token: ").strip()
                    payload["data"] = {"token": token}
                client.send_and_receive(payload)
            elif choice == '3':
                client.send_and_receive({
                    "type": "NOTIFICATIONS",
                    "action": "SUBSCRIBE"
                })
            elif choice == '4':
                json_str = input("Enter JSON message: ").strip()
                try:
                    payload = json.loads(json_str)
                    client.send_and_receive(payload)
                except json.JSONDecodeError:
                    print("❌ Invalid JSON")
            else:
                print("Invalid choice")
            
            print()
        except KeyboardInterrupt:
            print("\n")
            break
        except Exception as e:
            print(f"❌ Error: {e}")
    
    client.close()

def main():
    parser = argparse.ArgumentParser(description='WebSocket Test Client')
    parser.add_argument('--test-all', action='store_true', help='Test all endpoints')
    parser.add_argument('--message', type=str, help='Send custom JSON message')
    
    args = parser.parse_args()
    
    if args.test_all:
        test_all_endpoints()
    elif args.message:
        client = WebSocketClient(WS_HOST, WS_PORT)
        if client.connect():
            try:
                payload = json.loads(args.message)
                client.send_and_receive(payload)
            except json.JSONDecodeError:
                print("❌ Invalid JSON message")
            finally:
                client.close()
    else:
        interactive_mode()

if __name__ == "__main__":
    main()
