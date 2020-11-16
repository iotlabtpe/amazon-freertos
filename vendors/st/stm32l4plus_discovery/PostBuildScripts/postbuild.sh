#!/bin/bash -
#Post build for SECBOOT_ECCDSA_WITHOUT_ENCRYPT_SHA256
# arg1 is the build directory
# arg2 is the elf file path+name
# arg3 is the bin file path+name
# arg4 is the version
# arg5 when present forces "bigelf" generation
projectdir=$1
FileName=${3##*/}
execname=${FileName%.*}
elf=$2
bin=$3
version=$4

SecureEngine="."

userAppBinary="."

sfb=$userAppBinary"/"$execname".sfb"
sign=$userAppBinary"/"$execname".sign"
headerbin=$userAppBinary"/"$execname"sfuh.bin"
bigbinary=$userAppBinary"/SBSFU_"$execname".bin"
ecckey=$SecureEngine"/Binary/ECCKEY.txt"
current_directory=`pwd`

SecureDir=`pwd`
cd $current_directory
sbsfuelf="./B-L4S5I-IOT01_2_Images_SBSFU/Debug/SBSFU.elf"
fw_sign_ecckey="./Certs/sbsfu_fs_prv.pem"
cert_fw_leaf="./Certs/sbsfu_fs_crt.der"
cert_fw_inter="./Certs/sbsfu_i2_crt.der"

current_directory=`pwd`
cd ./KeysAndImages
basedir="../"
cd $current_directory
# test if window executeable useable
prepareimage=$current_directory"/prepareimage/prepareimage.exe"

echo $prepareimage
uname  | grep -i -e windows -e mingw > /dev/null 2>&1

echo "prepareimage with windows executeable"
export PATH=$basedir"/prepareimage":$PATH > /dev/null 2>&1
cmd=""
bigelftuner="./bigelftuner.exe"


echo "$cmd $prepareimage" > $1/output0.txt
# Make sure we have a Binary sub-folder in UserApp folder
if [ ! -e $userAppBinary ]; then
mkdir $userAppBinary
fi

echo "111223344"
echo "111223344"
echo "111223344"
echo "111223344"

command=$cmd" "$prepareimage" sha256 "$bin" "$sign
$command >> $projectdir"/output1.txt"

echo "5555"

ret=$?
if [ $ret = 0 ]; then
  command=$cmd" "$prepareimage" pack  -k "$fw_sign_ecckey" -p 1 -r 44 -v "$version" --cert_fw_inter "$cert_fw_inter" --cert_fw_leaf "$cert_fw_leaf" -f "$bin" -t "$sign" "$sfb" -o 2048"
  $command >> $projectdir"/output2.txt"
  echo "666"
  ret=$?
  if [ $ret = 0 ]; then
    command=$cmd" "$prepareimage" header -k  "$fw_sign_ecckey"  -p 1 -r 44 -v "$version"  -f "$bin" -t "$sign" -o 2048 --cert_fw_inter "$cert_fw_inter" --cert_fw_leaf "$cert_fw_leaf" "$headerbin
    $command >> $projectdir"/output3.txt"
    echo "777sbsfuelf"
    echo $sbsfuelf
    ls $sbsfuelf
	echo "777elf"
    echo $elf
	echo "777bigbin"
	echo $bigbinary
	echo "777headerbin"
	echo $headerbin
	echo "777prepareimage"
	echo $prepareimage
    ls $elf
    ret=$?
    if [ $ret = 0 ]; then
      command=$cmd" "$prepareimage" merge -v 0 -e 1 -i "$headerbin" -s "$sbsfuelf" -u "$elf" "$bigbinary
      $command >> $projectdir"/output4.txt"
      echo "8888"
      ret=$?
      if [ $ret = 0 ] && [ $# = 5 ]; then
        echo "Generating the global elf file (SBSFU and userApp)"
        echo "Generating the global elf file (SBSFU and userApp)" >> $projectdir"/output5.txt"
        uname | grep -i -e windows -e mingw > /dev/null 2>&1
        if [ $? = 0 ]; then
          # Set to the default installation path of the Cube Programmer tool
          # If you installed it in another location, please update PATH.
          PATH="C:\\Program Files\\STMicroelectronics\\STM32Cube\\STM32CubeProgrammer\\bin":$PATH > /dev/null 2>&1
          programmertool="STM32_Programmer_CLI.exe"
        else
          which STM32_Programmer_CLI > /dev/null
          if [ $? = 0 ]; then
            programmertool="STM32_Programmer_CLI"
          else
            echo "fix access path to STM32_Programmer_CLI"
          fi
        fi
        command=$programmertool" -ms "$elf" "$headerbin" "$sbsfuelf
        $command >> $projectdir"/output6.txt"
        ret=$?
        if [ $ret = 0 ]; then
          command=$cmd" "$bigelftuner" "$sbsfuelf" "$elf
          $command >> $projectdir"/output7.txt"
          ret=$?
        fi
      fi
    fi
  fi
fi

if [ $ret = 0 ]; then
  rm $sign
  rm $headerbin
  exit 0
else
  echo "$command : failed" >> $projectdir"/output8.txt"
  if [ -e  "$elf" ]; then
    rm  $elf
  fi
  if [ -e "$elfbackup" ]; then
    rm  $elfbackup
  fi
  echo $command : failed
  read -n 1 -s
  exit 1
fi