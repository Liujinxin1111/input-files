#!/bin/bash
#Setting
Prefix=$PWD
Folder=${Prefix##*/}
ComName="com"                           #复合物体系名称
ComPDB=$ComName".pdb"                       #复合物PDB文件
ComMDCrd="image.nc"         #野生型复合物无水轨迹文件，轨迹必须为NetCDF格式
RecName="pro"                               #受体名称
RecPDB=$RecName".pdb"                       #受体PDB文件
LigName="lig"                               #配体名称
LigPDB=$LigName".pdb"                       #配体PDB文件
#LigNameInPDB="MOL"                          #PDB文件中的配体残基三字符名称
#LigMol2File="ligand.mol2"               #tleap中所需的带电荷的gaff原子类型的配体mol2文件
#LigFrcmodFile="ligand.frcmod"                  #tleap中所需的配体frcmod文件
PBRadii="mbondi"                           #原子GB半径，使用igb=2时应该使用mbondi2半径
ResDielName="ResidueDielectric.dat"         #各残基对应的介电常数，蛋白N和C端的NH3+和COO-残基视作带电残基
FrameStart=1                             #待计算的轨迹起始帧数
FrameStop=10000                           #待计算的轨迹终止帧数
FrameOffset=100                           #待计算的轨迹帧间隔数
Processors=8                               #计算野生型体系的MMGBSA时的并行计算线程数
RemoveTemp=0                                #为1时删除中间文件

#Copy Files
rm -rf ../Wildtype AlaScan_GB.dat NearResidue.dat 
>nohup.out
mkdir ../Wildtype
cd ../Wildtype
ln -s "../"$Folder"/"$ComPDB .
ln -s "../"$Folder"/"$ComMDCrd .
ln -s "../"$Folder"/"$RecPDB .
ln -s "../"$Folder"/"$LigPDB .
cp "../"$Folder"/Prepare_GetTop_Wildtype.sh" GetTop_Wildtype.sh
cp "../"$Folder"/Prepare_RunMMPBSA.sh" RunMMPBSA_Wildtype.sh

#Get Top Files
sed -i -e "1,/ComName=/s/ComName=/&\"${ComName}\"/" GetTop_Wildtype.sh
sed -i -e "1,/ComPDB=/s/ComPDB=/&\"${ComPDB}\"/" GetTop_Wildtype.sh
sed -i -e "1,/RecName=/s/RecName=/&\"${RecName}\"/" GetTop_Wildtype.sh
sed -i -e "1,/RecPDB=/s/RecPDB=/&\"${RecPDB}\"/" GetTop_Wildtype.sh
sed -i -e "1,/LigName=/s/LigName=/&\"${LigName}\"/" GetTop_Wildtype.sh
sed -i -e "1,/LigPDB=/s/LigPDB=/&\"${LigPDB}\"/" GetTop_Wildtype.sh
sed -i -e "1,/LigNameInPDB=/s/LigNameInPDB=/&\"${LigNameInPDB}\"/" GetTop_Wildtype.sh
sed -i -e "1,/LigMol2File=/s/LigMol2File=/&\"..\/${Folder}\/${LigMol2File}\"/" GetTop_Wildtype.sh
sed -i -e "1,/LigFrcmodFile=/s/LigFrcmodFile=/&\"..\/${Folder}\/${LigFrcmodFile}\"/" GetTop_Wildtype.sh
sed -i -e "1,/PBRadii=/s/PBRadii=/&\"${PBRadii}\"/" GetTop_Wildtype.sh
bash GetTop_Wildtype.sh 1>/dev/null

#Run MMGBPBSA
sed -i -e "1,/Processors=/s/Processors=/&${Processors}/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_Complex=/s/NAME_Complex=/&\"${ComName}\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_Receptor=/s/NAME_Receptor=/&\"${RecName}\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_Ligand=/s/NAME_Ligand=/&\"${LigName}\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_ComplexTop=/s/NAME_ComplexTop=/&\"${ComName}.top\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_ReceptorTop=/s/NAME_ReceptorTop=/&\"${RecName}.top\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_LigandTop=/s/NAME_LigandTop=/&\"${LigName}.top\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_SolvatedTop=/s/NAME_SolvatedTop=/&\"${ComName}.top\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/NAME_Mdcrd=/s/NAME_Mdcrd=/&\"${ComMDCrd}\"/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/startframe=/s/startframe=/&${FrameStart}/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/endframe=/s/endframe=/&${FrameStop}/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/interval=/s/interval=/&${FrameOffset}/" RunMMPBSA_Wildtype.sh
Dielectric=`awk '{print $2}' "../"$Folder"/"$ResDielName | sort -g -u | xargs echo`
sed -i -e "1,/intdiel=/s/intdiel=/&(${Dielectric})/" RunMMPBSA_Wildtype.sh
sed -i -e "1,/indi=/s/indi=/&(${Dielectric})/" RunMMPBSA_Wildtype.sh
bash RunMMPBSA_Wildtype.sh

#Remove Temp Files
if [ $RemoveTemp -eq 1 ];then
    rm -f *.nc
    rm -f *.pdb
    rm -f *.top
    rm -f GetTop_Wildtype.sh
    rm -f RunMMPBSA_Wildtype.sh
    rm -f fort.200
fi
