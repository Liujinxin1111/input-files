#!/bin/bash
#Setting
Prefix=$PWD
Folder=${Prefix##*/}
ComName="com"               #复合物体系名称
DataFile="NearResidue.dat"      #配体周围残基文件
RemoveTemp=1                   #为1时删除中间文件
Parallel=2                      #并行计算单个残基ASMMGBSA的数量，计算需要的总线程数为Parallel*Processors（Step2中的）

#Do Prepare and MMGBPBSA
Sub_RunCalculate()
{
PPWD=`pwd`
Name=${PPWD##*/}
echo $Name" Calculating..." >> $Prefix"/Temp_Progress"
#GetTop
bash GetTop.sh 1>/dev/null
#Mutant MDCrd
bash RunMutant.sh 1>/dev/null
#MMGBPBSA Mutant
bash RunMMPBSA_Mut.sh 1>/dev/null
#Finished
if [ $RemoveTemp -eq 1 ];then
    rm -f *.nc
    rm -f *.pdb
    rm -f *.top
    rm -f GetTop.sh
    rm -f RunMutant.sh
    rm -f RunMMPBSA_Mut.sh
    rm -f fort.200
fi
echo $Name" Finished." >> $Prefix"/Temp_Progress"
}

#Wait
Sub_Wait()
{
while true;do
    Calculating=`grep "Calculating" Temp_Progress | wc -l`
    Finished=`grep "Finished" Temp_Progress | wc -l`
    if [ $[$Calculating-$Finished] -lt $Parallel ];then
        break
    fi
    sleep 1s 
done
}

#Run Calculate
echo "Start Running..." > Temp_Progress
Mutants=`cat $DataFile`
MutantNumber=`cat $DataFile | wc -l`
for mutant in $Mutants;do
    cd ..
    mutantName=`echo ${mutant:0:3}`
    mutantID=`echo ${mutant:3}`
    cd $ComName"_"$mutantID$mutantName
    echo $ComName"_"$mutantName$mutantID"ALA Calculating..."
    Sub_RunCalculate &
    cd "../"$Folder
    Sub_Wait
done

#Wait For All Finished
while true;do
    Finished=`grep "Finished" Temp_Progress | wc -l`
    if [ $Finished -eq $MutantNumber ];then
        break
    fi
    sleep 1s 
done
echo "All Finished." >> Temp_Progress
rm -f Temp_Progress
