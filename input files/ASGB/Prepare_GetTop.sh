#!/bin/bash
#Setting
Prefix=$PWD
ComName=
MutResID=
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

#Create GetMutComPDB.config
cat > GetMutComPDB.config << EOF
#configures for get alanine mutant PDB file
#file path (should end with /):
${Prefix}/
#complex name:
${ComName}
#mutant residue ID:
${MutResID}
#wildtype complex PDB file name:
${ComPDB}
#end
EOF

#Run GetMutComPDB
rm -f $ComName"_"???$MutResID???".pdb"
AlaScan_GetMutPDB GetMutComPDB.config 1>/dev/null

#Create GetMutRecPDB.config
cat > GetMutRecPDB.config << EOF
#configures for get alanine mutant PDB file
#file path (should end with /):
${Prefix}/
#receptor name:
${RecName}
#mutant residue ID:
${MutResID}
#wildtype receptor PDB file name:
${RecPDB}
#end
EOF

#Run GetMutRecPDB
rm -f $RecName"_"???$MutResID???".pdb"
AlaScan_GetMutPDB GetMutRecPDB.config 1>/dev/null

#Get Mutant Name
MutComName=`ls $ComName"_"???$MutResID???".pdb"`
MutComName=${MutComName%.*}
MutRecName=`ls $RecName"_"???$MutResID???".pdb"`
MutRecName=${MutRecName%.*}


#Create tleap.in
cat > tleap.in << EOF
source leaprc.protein.ff19SB
#source /oldff/leaprc.ff14SB
#source leaprc.protein.ff14SB
#source leaprc.gaff
#${LigNameInPDB}=loadmol2 ${LigMol2File}
#loadamberparams ${LigFrcmodFile}
MutRec=loadpdb ${MutRecName}.pdb
WidRec=loadpdb ${RecPDB}
Lig=loadpdb ${LigName}.pdb
MutCom=loadpdb ${MutComName}.pdb
WidCom=loadpdb ${ComPDB}
set default PBRadii ${PBRadii}

bond MutRec.14.SG MutRec.426.SG
bond MutRec.41.SG MutRec.65.SG
bond MutRec.107.SG MutRec.120.SG
bond MutRec.207.SG MutRec.220.SG
bond MutRec.212.SG MutRec.324.SG
bond MutRec.318.SG MutRec.328.SG
bond MutRec.390.SG MutRec.399.SG
 
bond WidRec.14.SG WidRec.426.SG
bond WidRec.41.SG WidRec.65.SG
bond WidRec.107.SG WidRec.120.SG
bond WidRec.207.SG WidRec.220.SG
bond WidRec.212.SG WidRec.324.SG
bond WidRec.318.SG WidRec.328.SG
bond WidRec.390.SG WidRec.399.SG

bond Lig.449.SG   Lig.523.SG
 
bond MutCom.14.SG MutCom.426.SG
bond MutCom.41.SG MutCom.65.SG
bond MutCom.107.SG MutCom.120.SG
bond MutCom.207.SG MutCom.220.SG
bond MutCom.212.SG  MutCom.324.SG
bond MutCom.318.SG  MutCom.328.SG
bond MutCom.390.SG  MutCom.399.SG
bond MutCom.449.SG  MutCom.523.SG
 
bond WidCom.14.SG WidCom.426.SG
bond WidCom.41.SG WidCom.65.SG
bond WidCom.107.SG WidCom.120.SG
bond WidCom.207.SG WidCom.220.SG
bond WidCom.212.SG  WidCom.324.SG
bond WidCom.318.SG  WidCom.328.SG
bond WidCom.390.SG  WidCom.399.SG
bond WidCom.449.SG  WidCom.523.SG

saveamberparm MutRec ${MutRecName}.top ${MutRecName}.crd
savepdb MutRec ${MutRecName}.pdb
saveamberparm WidRec ${RecName}.top ${RecName}.crd
saveamberparm Lig ${LigName}.top ${LigName}.crd
saveamberparm MutCom ${MutComName}.top ${MutComName}.crd
savepdb MutCom ${MutComName}.pdb
saveamberparm WidCom ${ComName}.top ${ComName}.crd
quit
EOF


tleap -s -f tleap.in 1>/dev/null
mv leap.log tleap.log


#Remove Temp Files
if [ $RemoveTemp -eq 1 ];then
    rm -f GetMutComPDB.config
    rm -f GetMutRecPDB.config
    rm -f tleap.in
    rm -f tleap.log
    rm -f $MutComName".crd"
    rm -f $MutRecName".crd"
    rm -f $LigName".crd"
    rm -f $ComName".crd"
    rm -f $RecName".crd"
fi
