        clear
        import excel "C:\Users\Sam\Desktop\While Out\Enrollment Public Schools 2017-18.xlsx", sheet("LEA and School") cellrange(A5:AB3268) firstrow case(lower)
        keep leatype schoolnumber total
        rename schoolnumber schl
        drop if mi(schl)
        drop if schl =="9999" | schl =="0000"
        tempfile enrollment
        save `enrollment' 
    clear


        import excel "C:\Users\Sam\Desktop\While Out\SchoolFastFacts.xlsx", sheet("Sheet2") firstrow case(lower)
        replace dataelement =trim(dataelement)
        gen keep=1 if inlist( dataelement, "White", "2 or More Races", "American Indian/Alaskan Native", "Asian" ,"Special Education")
        replace keep=1 if inlist( dataelement,  "Black/African American", "Native Hawaiian or other Pacific Islander", "Hispanic", "Economically Disadvantaged", "English Learner", "Percent of Gifted Students", "School Enrollment", "Intermediate Unit Name" )
        keep if keep==1
        replace dataelement ="2_or_more" if dataelement=="2 or More Races"
        replace dataelement ="native" if dataelement=="American Indian/Alaskan Native"
        replace dataelement ="asian" if dataelement=="Asian"
        replace dataelement ="black" if dataelement=="Black/African American"
        replace dataelement ="econ" if dataelement=="Economically Disadvantaged"
        replace dataelement ="hispanic" if dataelement=="Hispanic"
        replace dataelement ="islander" if dataelement=="Native Hawaiian or other Pacific Islander"
        replace dataelement ="white" if dataelement=="White"
        replace dataelement ="ell" if dataelement=="English Learner"
        replace dataelement ="gifted" if dataelement=="Percent of Gifted Students"
        replace dataelement ="sped" if dataelement=="Special Education"
        replace dataelement ="enrollment" if dataelement=="School Enrollment"
        replace dataelement ="county" if dataelement=="School Address (City)"
        replace dataelement ="iu" if dataelement=="Intermediate Unit Name"
        format displayvalue %20s
        rename displayvalue d_
        reshape wide d_ , i( districtname name aun schl) j( dataelement )s
        rename d_2_or_more race_2_or_more
        rename d_* *
        destring schl, force replace
        gen str4 z = string(schl,"%04.0f")
        drop schl*
        rename z schl
        drop keep
        order districtname name aun schl native  asian black islander white race_2_or_more hispanic ell sped gifted
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
        destring native-enrollment, force replace
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
        