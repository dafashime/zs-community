#!/usr/bin/env python3
"""G2/G2.5 core.bin / gplus.bin XXTEA length-frame unpacker and repacker."""
from pathlib import Path
import argparse, base64, struct
CORE_KEY=bytes.fromhex("3036393632633264656565363965303064393836643835363038623861666433")
GPLUS_KEY=bytes.fromhex("0fd48cf87774b614e5e377b3f216132765e37504c6a2a3f2f3c30314c716f707a40213738396c586b707e3830297b4c506e6d7178303233782538396c6d716c647863246f7")
def decrypt(data,key):
 key=key.ljust(16,b"\0")[:16];n=len(data)//4;v=list(struct.unpack(f"<{n}I",data[:n*4]));k=list(struct.unpack("<4I",key));d=0x9E3779B9;s=((6+52//n)*d)&0xffffffff
 while s:
  e=(s>>2)&3
  for p in range(n-1,0,-1):
   z,y=v[p-1],v[(p+1)%n];m=(((z>>5^y<<2)+(y>>3^z<<4))^((s^y)+(k[(p&3)^e]^z)));v[p]=(v[p]-m)&0xffffffff
  z,y=v[n-1],v[1];m=(((z>>5^y<<2)+(y>>3^z<<4))^((s^y)+(k[e]^z)));v[0]=(v[0]-m)&0xffffffff;s=(s-d)&0xffffffff
 return struct.pack(f"<{n}I",*v)
def encrypt(data,key):
 key=key.ljust(16,b"\0")[:16]
 if len(data)%4:data+=b"\0"*(4-len(data)%4)
 n=len(data)//4;v=list(struct.unpack(f"<{n}I",data));k=list(struct.unpack("<4I",key));d=0x9E3779B9;s=0
 for _ in range(6+52//n):
  s=(s+d)&0xffffffff;e=(s>>2)&3
  for p in range(n):
   y,z=v[(p+1)%n],v[(p-1)%n];m=(((z>>5^y<<2)+(y>>3^z<<4))^((s^y)+(k[(p&3)^e]^z)));v[p]=(v[p]+m)&0xffffffff
 return struct.pack(f"<{n}I",*v)
def unpack_frame(cipher,key):
 f=decrypt(cipher,key);size=struct.unpack("<I",f[-4:])[0];pad=len(f)-4-size
 if not 0<=pad<=3 or f[size:-4]!=b"\0"*pad:raise ValueError("invalid length trailer")
 return f[:size]
def pack_frame(payload,key):return encrypt(payload+b"\0"*((4-len(payload)%4)%4)+struct.pack("<I",len(payload)),key)
def main():
 p=argparse.ArgumentParser();p.add_argument("mode",choices=["unpack-core","pack-core","unpack-gplus","pack-gplus"]);p.add_argument("input",type=Path);p.add_argument("output",type=Path);a=p.parse_args();key=CORE_KEY if "core" in a.mode else GPLUS_KEY;data=a.input.read_bytes();result=unpack_frame(data,key) if a.mode.startswith("unpack") else pack_frame(data,key);a.output.write_bytes(result)
 if a.mode=="unpack-gplus":
  parts=result.split(b"#")
  if len(parts)==11:a.output.with_suffix(".payload.bin").write_bytes(base64.b64decode(parts[-1]))
if __name__=="__main__":main()
