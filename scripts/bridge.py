#!/usr/bin/env python3
"""
TeaYield AI Development Bridge
Routes requests from the macOS iOS Simulator (127.0.0.1:8000) to the FastAPI backend on the Linux host (10.0.2.2:8000).
"""
import socket
import threading
import sys

LOCAL_HOST = "127.0.0.1"
LOCAL_PORT = 8000
REMOTE_HOST = "10.0.2.2"
REMOTE_PORT = 8000

def forward(source, destination):
    try:
        while True:
            data = source.recv(4096)
            if not data:
                break
            destination.sendall(data)
    except Exception:
        pass
    finally:
        source.close()
        destination.close()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind((LOCAL_HOST, LOCAL_PORT))
        server.listen(5)
        print(f"TeaYield AI Bridge running: http://{LOCAL_HOST}:{LOCAL_PORT} -> http://{REMOTE_HOST}:{REMOTE_PORT}")
        print("Press Ctrl+C to stop.")
    except Exception as error:
        print(f"Failed to bind {LOCAL_HOST}:{LOCAL_PORT}: {error}")
        sys.exit(1)

    while True:
        try:
            client_socket, _ = server.accept()
            remote_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            remote_socket.connect((REMOTE_HOST, REMOTE_PORT))

            t1 = threading.Thread(target=forward, args=(client_socket, remote_socket), daemon=True)
            t2 = threading.Thread(target=forward, args=(remote_socket, client_socket), daemon=True)
            t1.start()
            t2.start()
        except KeyboardInterrupt:
            print("\nBridge stopped.")
            break
        except Exception as error:
            print(f"Connection error: {error}")

if __name__ == "__main__":
    main()
