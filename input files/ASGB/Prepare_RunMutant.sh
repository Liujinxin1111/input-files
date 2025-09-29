#!/bin/bash
#Setting
Prefix=$PWD
ComName=
MutResID=
ComPDB=
ComMDCrd=
FirstFrame=
LastFrame=
OffsetFrame=
RemoveTemp=1

#Create GetMutMDCrd.config
cat > GetMutMDCrd.config << EOF
#configures for get alanine mutant NC file
#file path (should end with /):
${Prefix}/
#complex name:
${ComName}
#mutant residue ID:
${MutResID}
#wildtype complex PDB file name:
${ComPDB}
#wildtype complex NC file name:
${ComMDCrd}
#first frame of NC file:
${FirstFrame}
#last frame of NC file:
${LastFrame}
#offset frame of NC file:
${OffsetFrame}
#end
EOF

#Run GetMutMDCrd
rm -f $ComName"_"???$MutResID???".nc"
AlaScan_GetMutMDCrd GetMutMDCrd.config 1>/dev/null


#Remove Temp Files
if [ $RemoveTemp -eq 1 ];then
    rm -f GetMutMDCrd.config
fi
