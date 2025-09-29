#!/bin/bash

Processors=
RemoveTemp=1

###Setting
### Flie Names
    NAME_Complex=
    NAME_Receptor=
    NAME_Ligand=
    NAME_ComplexTop=
    NAME_ReceptorTop=
    NAME_LigandTop=
    NAME_SolvatedTop=
    NAME_Mdcrd=
### Calculate Types
    DO_GB=1
    DO_PB=0
### Data for General
    startframe=
    endframe=
    interval=
    use_sander=1
    netcdf=1
    keep_files=0
    debug_printlevel=0
    verbose=1
### Data for GBSA
    igb=1
    intdiel=
    extdiel=80.0
    saltcon=0.000
    ifqnt=0
    molsurf=0
    surften=0.0072
    surfoff=0.00000
### Data for PBSA
    indi=
    exdi=80.0
    istrng=0.000
    fillratio=4.0
    scale=2.0
    linit=1000
    inp=1
    radiopt=0
    cavity_surften=0.00542
    cavity_offset=0.92000

###Remove Possible Old Files
rm -f _MMPBSA_*
rm -f Log_*.log
rm -f In_*.in
rm -f $NAME_Complex"_MMGBSA_"*".dat"
rm -f $NAME_Complex"_MMGBSA_"*".csv"
rm -f $NAME_Complex"_MMPBSA_"*".dat"
rm -f $NAME_Complex"_MMPBSA_"*".csv"
FlagError=0

###Create In_MMGBSA.in Files
if [ $DO_GB -eq 1 ];then
    for ((temp=0; temp<${#intdiel[*]}; temp=temp+1));do
        echo "MMGBSA control file" > "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
        echo "&general" >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""startframe="$startframe"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""endframe="$endframe"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""interval="$interval"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""use_sander="$use_sander"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""netcdf="$netcdf"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""keep_files="$keep_files"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""debug_printlevel="$debug_printlevel"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""verbose="$verbose"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""entropy=0""," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
        echo "/" >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
        echo "&gb" >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""igb="$igb"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""saltcon="$saltcon"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""ifqnt="$ifqnt"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""molsurf="$molsurf"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""surften="$surften"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
            echo -e "\t""surfoff="$surfoff"," >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"    
        echo "/" >> "In_MMGBSA_intdiel="${intdiel[$temp]}".in"
    done
fi

###Create In_MMPBSA.in Files
if [ $DO_PB -eq 1 ];then
    for ((temp=0; temp<${#indi[*]}; temp=temp+1));do
        echo "MMPBSA control file" > "In_MMPBSA_indi="${indi[$temp]}".in"
        echo "&general" >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""startframe="$startframe"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""endframe="$endframe"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""interval="$interval"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""use_sander="$use_sander"," >> "In_MMPBSA_indi="${indi[$temp]}".in"    
            echo -e "\t""netcdf="$netcdf"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""keep_files="$keep_files"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""debug_printlevel="$debug_printlevel"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""verbose="$verbose"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""entropy=0""," >> "In_MMPBSA_indi="${indi[$temp]}".in"
        echo "/" >> "In_MMPBSA_indi="${indi[$temp]}".in"
        echo "&pb" >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""indi="${indi[$temp]}"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""exdi="$exdi"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""istrng="$istrng"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""fillratio="$fillratio"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""scale="$scale"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""linit="$linit"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""inp="$inp"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""radiopt="$radiopt"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""cavity_surften="$cavity_surften"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
            echo -e "\t""cavity_offset="$cavity_offset"," >> "In_MMPBSA_indi="${indi[$temp]}".in"
        echo "/" >> "In_MMPBSA_indi="${indi[$temp]}".in"
    done
fi

###Calculate MMGBSA
if [ $DO_GB -eq 1 ];then
    for ((temp=0; temp<${#intdiel[*]}; temp=temp+1));do
        mpirun -np $Processors MMPBSA.py.MPI -O -i "In_MMGBSA_intdiel="${intdiel[$temp]}".in" -o $NAME_Complex"_MMGBSA_intdiel="${intdiel[$temp]}".dat" -eo $NAME_Complex"_MMGBSA_intdiel="${intdiel[$temp]}".csv" -sp $NAME_SolvatedTop -cp $NAME_ComplexTop -rp $NAME_ReceptorTop -lp $NAME_LigandTop -y $NAME_Mdcrd -make-mdins >> "Log_MMGBSA_intdiel="${intdiel[$temp]}".log" 2>&1
        sed -i -e "1,/extdiel=${extdiel},/s/extdiel=${extdiel},/& intdiel=${intdiel[$temp]},/" _MMPBSA_gb.mdin
        mpirun -np $Processors MMPBSA.py.MPI -O -i "In_MMGBSA_intdiel="${intdiel[$temp]}".in" -o $NAME_Complex"_MMGBSA_intdiel="${intdiel[$temp]}".dat" -eo $NAME_Complex"_MMGBSA_intdiel="${intdiel[$temp]}".csv" -sp $NAME_SolvatedTop -cp $NAME_ComplexTop -rp $NAME_ReceptorTop -lp $NAME_LigandTop -y $NAME_Mdcrd -use-mdins >> "Log_MMGBSA_intdiel="${intdiel[$temp]}".log" 2>&1        
    done
fi

###Calculate MMPBSA
if [ $DO_PB -eq 1 ];then
    for ((temp=0; temp<${#indi[*]}; temp=temp+1));do
        mpirun -np $Processors MMPBSA.py.MPI -O -i "In_MMPBSA_indi="${indi[$temp]}".in" -o $NAME_Complex"_MMPBSA_indi="${indi[$temp]}".dat" -eo $NAME_Complex"_MMPBSA_indi="${indi[$temp]}".csv" -sp $NAME_SolvatedTop -cp $NAME_ComplexTop -rp $NAME_ReceptorTop -lp $NAME_LigandTop -y $NAME_Mdcrd -make-mdins >> "Log_MMPBSA_indi="${indi[$temp]}".log" 2>&1
        sed -i -e "1,/radiopt=${radiopt},/s/radiopt=${radiopt},/& use_sav=0, sprob=1.4,/" _MMPBSA_pb.mdin
        mpirun -np $Processors MMPBSA.py.MPI -O -i "In_MMPBSA_indi="${indi[$temp]}".in" -o $NAME_Complex"_MMPBSA_indi="${indi[$temp]}".dat" -eo $NAME_Complex"_MMPBSA_indi="${indi[$temp]}".csv" -sp $NAME_SolvatedTop -cp $NAME_ComplexTop -rp $NAME_ReceptorTop -lp $NAME_LigandTop -y $NAME_Mdcrd -use-mdins >> "Log_MMPBSA_indi="${indi[$temp]}".log" 2>&1
    done
fi

###Remove Temp Files
if [ $RemoveTemp -eq 1 ];then
    rm -f _MMPBSA_*
    rm -f Log_*.log
    rm -f In_*.in
fi
