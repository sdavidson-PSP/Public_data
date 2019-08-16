*Set Working Directory (THIS WILL NEED TO CHANGE TO THE FOLDER ALL THE PULLED DATA IS IN)
    cd C:\Users\Sam\Documents\GitHub\Public_data\        
        
        clear
        import excel "Enrollment Public Schools 2017-18 without Race.xlsx", sheet("LEA and School") cellrange(A5:AB3268) firstrow case(lower)   
        keep leatype schoolnumber total
        rename schoolnumber schl
        drop if mi(schl)
        drop if schl =="9999" | schl =="0000"
        tempfile enrollment
        save `enrollment' 
    clear

        import excel "SchoolFastFacts_20172018.xlsx", sheet("Sheet1") firstrow case(lower)
        replace dataelement =trim(dataelement)
        keep if inlist( dataelement,  "Black/African American", "Hispanic", "Economically Disadvantaged", "School Enrollment", "Intermediate Unit Name" )
        replace dataelement ="black" if dataelement=="Black/African American"
        replace dataelement ="econ" if dataelement=="Economically Disadvantaged"
        replace dataelement ="hispanic" if dataelement=="Hispanic"
        replace dataelement ="enrollment" if dataelement=="School Enrollment"
        replace dataelement ="county" if dataelement=="School Address (City)"
        replace dataelement ="iu" if dataelement=="Intermediate Unit Name"
        format displayvalue %20s
        rename displayvalue d_
        reshape wide d_ , i( districtname name aun schl) j( dataelement )s
        rename d_* *
        destring schl, force replace
        gen str4 z = string(schl,"%04.0f")
        drop schl*
        rename z schl
        order districtname name aun schl black hispanic econ
        tempfile demo
        save `demo'
    clear         

        use `demo'
        merge 1:1 schl using `enrollment'
        keep if _merge==3
        drop _merge
        tempfile base
        save `base'
    clear

        use `base'
        gen charter=1 if leatype =="CS"
        egen has_charters=sum(charter), by(iu)
        destring black hispanic econ enrollment, force replace
        gen black_count= black *enrollment /100
        gen hispanic_count= hispanic*enrollment /100
        gen econ_count= econ *enrollment /100
        
*Demographic comparison
    *table 1
        tabstat black [fweight=total], by(leatype) stat(mean p50)
    *table 2    
        tabstat hispanic [fweight=total], by(leatype) stat(mean p50)
    *table 3    
        tabstat econ [fweight=total], by(leatype) stat(mean p50)
    *table 4    
        tabstat black if iu!="Philadelphia IU 26" [fweight=total], by(leatype) stat(mean p50 n)
    *table 5    
        tabstat hispanic if iu!="Philadelphia IU 26" [fweight=total], by(leatype) stat(mean p50 n)
    *table 6    
        tabstat econ if iu!="Philadelphia IU 26" [fweight=total], by(leatype) stat(mean p50 n)

    preserve
        keep if leatype =="CS" | leatype =="SD"
    *table 7    
        ttest black, by(leatype) unequal
    *table 8    
        ttest hispanic, by(leatype) unequal
    *table 9    
        ttest econ , by(leatype) unequal
    *table 10
        tabstat black_count , by(leatype) stat(sum)
    *table 11
        tabstat hispanic_count  , by(leatype) stat(sum)
    *table 12       
        tabstat econ_count , by(leatype) stat(sum)
    *table 13
        tabstat enrollment  , by(leatype) stat(sum)
    *table 14
        collapse (mean) black hispanic econ [fweight=enrollment]    
    restore 
        