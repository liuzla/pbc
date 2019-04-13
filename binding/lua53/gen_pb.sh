#!/bin/bash

echo "do protoc all proto to pb......................"
rpath="./proto/"
wpath="./pb/"
# echo "find ${rpath} -name *.proto"
# echo "ls ${rpath}"
for fullname in `find ${rpath} -name *.proto`;
do
	fname="${fullname##*/}"
	echo "protoc -o ${wpath}${fname%%.*}.pb ${fullname}"
	protoc -o ${wpath}${fname%%.*}.pb ${fullname}
done 
echo "done protoc all proto to pb....................."

