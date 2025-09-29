#!/bin/bash
#Setting
Prefix=$PWD
ComName=
ComPDB=
RecName=
RecPDB=
LigName=
LigPDB=
LigNameInPDB=
LigMol2File=
LigFrcmodFile=
PBRadii=
RemoveTemp=0


#Create tleap.in
cat > tleap.in << EOF
source  leaprc.protein.ff14SB
#source oldff/leaprc.ff14SB
#source leaprc.protein.ff14SB
#source leaprc.gaff
#${LigNameInPDB}=loadmol2 ${LigMol2File}
#loadamberparams ${LigFrcmodFile}
WidRec=loadpdb ${RecPDB}
Lig=loadpdb ${LigName}.pdb
WidCom=loadpdb ${ComPDB}
set default PBRadii ${PBRadii}

bond WidRec.14.SG WidRec.426.SG
bond WidRec.41.SG WidRec.65.SG
bond WidRec.107.SG WidRec.120.SG
bond WidRec.207.SG WidRec.220.SG
bond WidRec.212.SG WidRec.324.SG
bond WidRec.318.SG WidRec.328.SG
bond WidRec.390.SG WidRec.399.SG

bond Lig.449.SG   Lig.523.SG

bond WidCom.14.SG WidCom.426.SG
bond WidCom.41.SG WidCom.65.SG
bond WidCom.107.SG WidCom.120.SG
bond WidCom.207.SG WidCom.220.SG
bond WidCom.212.SG  WidCom.324.SG
bond WidCom.318.SG  WidCom.328.SG
bond WidCom.390.SG  WidCom.399.SG
bond WidCom.449.SG  WidCom.523.SG

saveamberparm WidRec ${RecName}.top ${RecName}.crd
saveamberparm Lig ${LigName}.top ${LigName}.crd
saveamberparm WidCom ${ComName}.top ${ComName}.crd
quit
EOF


#Run tleap
tleap -s -f tleap.in 1>/dev/null
mv leap.log tleap.log


if [ $RemoveTemp -eq 1 ];then	
    rm -f tleap.in
    rm -f tleap.log
    rm -f $LigName".crd"
    rm -f $ComName".crd"i
    rm -f $RecName".crd"
fi  
