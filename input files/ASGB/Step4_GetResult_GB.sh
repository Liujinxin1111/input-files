#!/bin/bash
#Setting
Prefix=$PWD
Folder=${Prefix##*/}
ComName="com"                       #复合物体系名称
ComPDB=$ComName".pdb"                   #复合物PDB文件
DataFile="NearResidue.dat"              #配体周围残基文件
ResDielName="ResidueDielectric.dat"     #各残基对应的介电常数，蛋白N和C端的NH3+和COO-残基视作带电残基
DO_GB=1                                 #为1时统计ASMMGBSA结果
DO_PB=0                                 #为1时统计ASMMPBSA结果，PB计算为预留功能，未经过测试，默认不计算
OutFileGB="AlaScan_GB.dat"              #输出的ASMMGBSA结果文件
OutFilePB="AlaScan_PB.dat"              #输出的ASMMPBSA结果文件

#Get N Head and C Tail Residue
ResNumber=`grep "ATOM" $ComPDB | tail -n 1 | awk '{print $5}'`
for ((i=1;i<=$ResNumber;i++));do
    NRes[$i]=0
    CRes[$i]=0
done
while read -r Line;do
    if [ ${Line:0:4} == "ATOM" ];then
        ResName=${Line:17:3}
        ResID=${Line:22:4}
        AtomName=${Line:12:4}
        ResName=${ResName// /}
        ResID=${ResID// /}
        AtomName=${AtomName// /}
        case $ResName in
            "GLY" | "ALA" | "VAL" | "LEU" | "ILE" | "PHE" | "TRP" | "TYR" | "ASP" | "ASH" | "ASN" | "GLU" | "GLH" | "LYS" | "LYN" | "GLN" | "MET" | "SER" | "THR" | "CYS" | "CYX" | "CYM" | "HIE" | "HID" | "HIP" | "ARG" | "PRO")
                if [ "$AtomName" == "H2" ];then
                    NRes[$ResID]=1
                fi
                if [ "$AtomName" == "OXT" ];then
                    CRes[$ResID]=1
                fi
            ;;
        esac
    fi
done < $ComPDB

#Read Dielectric Constant for Residues
TotalRes=`cat $ResDielName | wc -l`
for (( n=1; n<=${TotalRes}; n=n+1 ));do
    ResidueName[$n]=`head -n $n $ResDielName | tail -n 1 | awk '{print $1}'`
    ResidueDiel[$n]=`head -n $n $ResDielName | tail -n 1 | awk '{print $2}'`
done

#Get GB Data
if [ $DO_GB -eq 1 ];then
    echo $ComName" Alanine Scanning MMGBSA Result: --> "$OutFileGB
    rm -f $OutFileGB
    printf "%7s %9s %9s %9s %9s %9s %9s %9s %9s %9s %9s\n" "Mut-Wid" "dVDW" "std_vdw" "dEEL" "std_ele" "dGB" "std_gb" "dNP" "std_np" "dH" "std_H" | tee -a $OutFileGB
    Mutants=`cat $DataFile`
    TotalMutants=`cat $DataFile | wc -l`
    Number=0
    for mutant in $Mutants;do
        Number=$[$Number+1]
        cd ..
        mutantName=`echo ${mutant:0:3}`
        mutantID=`echo ${mutant:3}`
        if [ ${NRes[$mutantID]} = 1 ];then
            mutantName2="N"$mutantName
        elif [ ${CRes[$mutantID]} = 1 ];then
            mutantName2="C"$mutantName
        else
            mutantName2=$mutantName
        fi
        for (( n=1; n<=$TotalRes; n=n+1 ));do
            if [ ${ResidueName[$n]} = $mutantName2 ];then
                Dielectric=${ResidueDiel[$n]}
                break
            fi
        done
        cd $ComName"_"$mutantID$mutantName
        VDWm=`grep "VDWAALS" $ComName"_"$mutantName$mutantID"ALA_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        VDWw=`grep "VDWAALS" "../Wildtype/"$ComName"_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dVDW[$Number]=`echo $VDWm - $VDWw | bc`
        
        ###processing csv file
        sed -n '313,412p' $ComName"_"$mutantName$mutantID"ALA_MMGBSA_intdiel="$Dielectric".csv" >M.dat
        sed -n '313,412p' "../Wildtype/"$ComName"_MMGBSA_intdiel="$Dielectric".csv" >W.dat
        awk -F ','  '{print $1,$2,$3,$4,$5,$6,$7,$8}' M.dat >M_out.dat
        awk -F ','  '{print $1,$2,$3,$4,$5,$6,$7,$8}' W.dat >W_out.dat
        paste M_out.dat W_out.dat >together.dat
        awk '{print $1,$10-$2,$11-$3,$12-$4,$13-$5,$14-$6,$15-$7,$16-$8}' together.dat >dd.dat
        awk '{print  $2}' dd.dat > tot.dat
        paste tot.dat >>../tot.dat
        #calculate std for vdw
        u_vdw=`cat dd.dat |awk '{sum+=$2} END {print sum/NR}'`
        std_vdw=`cat dd.dat |awk '{sum+=($2-u_vdw)*($2-u_vdw)} END {print sqrt(sum/NR)}' u_vdw="$u_vdw"`
        echo "the u of vdw =$u_vdw" >>std.dat
        echo "the std of vdw =$std_vdw" >>std.dat
        
        EELm=`grep "EEL" $ComName"_"$mutantName$mutantID"ALA_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        EELw=`grep "EEL" "../Wildtype/"$ComName"_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dEEL[$Number]=`echo $EELm - $EELw | bc`
        #calculate std for ele
        u_ele=`cat dd.dat |awk '{sum+=$3} END {print sum/NR}'`
        std_ele=`cat dd.dat |awk '{sum+=($3-u_ele)*($3-u_ele)} END {print sqrt(sum/NR)}' u_ele="$u_ele"`
        echo "the u of ele =$u_ele" >>std.dat
        echo "the std of ele =$std_ele" >>std.dat 
        
        GBm=`grep "EGB" $ComName"_"$mutantName$mutantID"ALA_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        GBw=`grep "EGB" "../Wildtype/"$ComName"_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dGB[$Number]=`echo $GBm - $GBw | bc`
        #calculate std for gb
        u_gb=`cat dd.dat |awk '{sum+=$4} END {print sum/NR}'`
        std_gb=`cat dd.dat |awk '{sum+=($4-u_gb)*($4-u_gb)} END {print sqrt(sum/NR)}' u_gb="$u_gb"`
        echo "the u of gb =$u_gb" >>std.dat
        echo "the std of gb =$std_gb" >>std.dat
    
        NPm=`grep "ESURF" $ComName"_"$mutantName$mutantID"ALA_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        NPw=`grep "ESURF" "../Wildtype/"$ComName"_MMGBSA_intdiel="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dNP[$Number]=`echo $NPm - $NPw | bc`
        #calculate std for np
        u_np=`cat dd.dat |awk '{sum+=$5} END {print sum/NR}'`
        std_np=`cat dd.dat |awk '{sum+=($5-u_np)*($5-u_np)} END {print sqrt(sum/NR)}' u_np="$u_np"`
        echo "the u of np =$u_np" >>std.dat
        echo "the std of np =$std_np" >>std.dat
        Hm=`grep "DELTA TOTAL" $ComName"_"$mutantName$mutantID"ALA_MMGBSA_intdiel="$Dielectric".dat" | awk '{print $3}'`
        Hw=`grep "DELTA TOTAL" "../Wildtype/"$ComName"_MMGBSA_intdiel="$Dielectric".dat" | awk '{print $3}'`
        dH[$Number]=`echo $Hm - $Hw | bc`
        #calculate std for H
        u_H=`cat dd.dat |awk '{sum+=$8} END {print sum/NR}'`
        std_H=`cat dd.dat |awk '{sum+=($8-u_H)*($8-u_H)} END {print sqrt(sum/NR)}' u_H="$u_H"`
        echo "the u of H =$u_H" >>std.dat
        echo "the std of H =$std_H" >>std.dat
        awk '{print  $8}' dd.dat > tot.dat
        paste tot.dat >> ../tot.dat
        cd "../"$Folder
        printf "%4s%3s %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\n" $mutantID $mutantName ${dVDW[$Number]} ${std_vdw} ${dEEL[$Number]} ${std_ele} ${dGB[$Number]} ${std_gb} ${dNP[$Number]} ${std_np} ${dH[$Number]} ${std_H} | tee -a $OutFileGB
    done
    TdVDW=0;TdEEL=0;TdGB=0;TdNP=0;TdH=0
    for (( n=1; n<=$TotalMutants; n=n+1 ));do
        TdVDW=`echo $TdVDW + ${dVDW[$n]} | bc`
        TdEEL=`echo $TdEEL + ${dEEL[$n]} | bc`
        TdGB=`echo $TdGB + ${dGB[$n]} | bc`
        TdNP=`echo $TdNP + ${dNP[$n]} | bc`
        TdH=`echo $TdH + ${dH[$n]} | bc`
    done
    printf "%7s %9.4f %9.4s %9.4f %9.4s %9.4f  %9.4s %9.4f %9.4s %9.4f\n" "TOTAL" $TdVDW " " $TdEEL " " $TdGB "  " $TdNP "  " $TdH | tee -a $OutFileGB
    echo ""
fi

#Get PB Data
if [ $DO_PB -eq 1 ];then
    echo $ComName" Alanine Scanning MMPBSA Result: --> "$OutFilePB
    rm -f $OutFilePB
    printf "%7s %9s %9s %9s %9s %9s %9s %9s %9s %9s %9s\n" "Mut-Wid" "dVDW" "std_vdw" "dEEL" "std_ele" "dPB" "std_pb" "dNP" "std_np" "dH" "std_H" | tee -a $OutFilePB
    Mutants=`cat $DataFile`
    TotalMutants=`cat $DataFile | wc -l`
    Number=0
    for mutant in $Mutants;do
        Number=$[$Number+1]
        cd ..
        mutantName=`echo ${mutant:0:3}`
        mutantID=`echo ${mutant:3}`
        if [ ${NRes[$mutantID]} = 1 ];then
            mutantName2="N"$mutantName
        elif [ ${CRes[$mutantID]} = 1 ];then
            mutantName2="C"$mutantName
        else
            mutantName2=$mutantName
        fi
        for (( n=1; n<=$TotalRes; n=n+1 ));do
            if [ ${ResidueName[$n]} = $mutantName2 ];then
                Dielectric=${ResidueDiel[$n]}
                break
            fi
        done
        cd $ComName"_"$mutantID$mutantName
        VDWm=`grep "VDWAALS" $ComName"_"$mutantName$mutantID"ALA_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        VDWw=`grep "VDWAALS" "../Wildtype/"$ComName"_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dVDW[$Number]=`echo $VDWm - $VDWw | bc`
        EELm=`grep "EEL" $ComName"_"$mutantName$mutantID"ALA_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        EELw=`grep "EEL" "../Wildtype/"$ComName"_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dEEL[$Number]=`echo $EELm - $EELw | bc`
        PBm=`grep "EPB" $ComName"_"$mutantName$mutantID"ALA_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        PBw=`grep "EPB" "../Wildtype/"$ComName"_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dPB[$Number]=`echo $PBm - $PBw | bc`
        NPm=`grep "ENPOLAR" $ComName"_"$mutantName$mutantID"ALA_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        NPw=`grep "ENPOLAR" "../Wildtype/"$ComName"_MMPBSA_indi="$Dielectric".dat" | tail -n 1 | awk '{print $2}'`
        dNP[$Number]=`echo $NPm - $NPw | bc`
        Hm=`grep "DELTA TOTAL" $ComName"_"$mutantName$mutantID"ALA_MMPBSA_indi="$Dielectric".dat" | awk '{print $3}'`
        Hw=`grep "DELTA TOTAL" "../Wildtype/"$ComName"_MMPBSA_indi="$Dielectric".dat" | awk '{print $3}'`
        dH[$Number]=`echo $Hm - $Hw | bc`
      ###processing csv file
        sed -n '613,812p' $ComName"_"$mutantName$mutantID"ALA_MMPBSA_indi="$Dielectric".csv" >M.dat
        sed -n '613,812p' "../Wildtype/"$ComName"_MMPBSA_indi="$Dielectric".csv" >W.dat
        awk -F ','  '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' M.dat >M_out.dat
        awk -F ','  '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' W.dat >W_out.dat
        paste M_out.dat W_out.dat >together.dat
        awk '{print $1,$11-$2,$12-$3,$13-$4,$14-$5,$15-$6,$16-$7,$17-$8,$18-$9}' together.dat >dd.dat
        awk '{print  $2}' dd.dat > tot.dat
        paste tot.dat >> ../tot.dat
        #calculate std for vdw
        u_vdw=`cat dd.dat |awk '{sum+=$2} END {print sum/NR}'`
        std_vdw=`cat dd.dat |awk '{sum+=($2-u_vdw)*($2-u_vdw)} END {print sqrt(sum/NR)}' u_vdw="$u_vdw"`
        echo "the u of vdw =$u_vdw" >>std.dat
        echo "the std of vdw =$std_vdw" >>std.dat
        #calculate std for ele
        u_ele=`cat dd.dat |awk '{sum+=$3} END {print sum/NR}'`
        std_ele=`cat dd.dat |awk '{sum+=($3-u_ele)*($3-u_ele)} END {print sqrt(sum/NR)}' u_ele="$u_ele"`
        echo "the u of ele =$u_ele" >>std.dat
        echo "the std of ele =$std_ele" >>std.dat
        #calculate std for pb
        u_pb=`cat dd.dat |awk '{sum+=$4} END {print sum/NR}'`
        std_pb=`cat dd.dat |awk '{sum+=($4-u_pb)*($4-u_pb)} END {print sqrt(sum/NR)}' u_pb="$u_pb"`
        echo "the u of pb =$u_pb" >>std.dat
        echo "the std of pb =$std_pb" >>std.dat
        #calculate std for np
        u_np=`cat dd.dat |awk '{sum+=$5} END {print sum/NR}'`
        std_np=`cat dd.dat |awk '{sum+=($5-u_np)*($5-u_np)} END {print sqrt(sum/NR)}' u_np="$u_np"`
        echo "the u of np =$u_np" >>std.dat
        echo "the std of np =$std_np" >>std.dat
        #calculate std for H
        u_H=`cat dd.dat |awk '{sum+=$9} END {print sum/NR}'`
        std_H=`cat dd.dat |awk '{sum+=($9-u_H)*($9-u_H)} END {print sqrt(sum/NR)}' u_H="$u_H"`
        echo "the u of H =$u_H" >>std.dat
        echo "the std of H =$std_H" >>std.dat


        cd "../"$Folder
         printf "%4s%3s %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\n" $mutantID $mutantName ${dVDW[$Number]} ${std_vdw} ${dEEL[$Number]} ${std_ele} ${dPB[$Number]} ${std_pb} ${dNP[$Number]} ${std_np} ${dH[$Number]} ${std_H} | tee -a $OutFilePB
    done
    TdVDW=0;TdEEL=0;TdPB=0;TdNP=0;TdH=0
    for (( n=1; n<=$TotalMutants; n=n+1 ));do
        TdVDW=`echo $TdVDW + ${dVDW[$n]} | bc`
        TdEEL=`echo $TdEEL + ${dEEL[$n]} | bc`
        TdPB=`echo $TdPB + ${dPB[$n]} | bc`
        TdNP=`echo $TdNP + ${dNP[$n]} | bc`
        TdH=`echo $TdH + ${dH[$n]} | bc`
    done
    printf "%7s %9.4f %9.4s %9.4f %9.4s %9.4f  %9.4s %9.4f %9.4s %9.4f\n" "TOTAL" $TdVDW " " $TdEEL " " $TdPB "  " $TdNP "  " $TdH | tee -a $OutFilePB
    echo ""
fi
