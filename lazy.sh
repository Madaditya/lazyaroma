#!/bin/bash
uline='\e[4m'
bold='\e[21m'
black='\e[30m'
magenta='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
red='\e[35m'
cyan='\e[36m'
blink='\e[5m'
endc='\e[0m'
default='\e[39m'
bgblue='\e[44m'
bglgray='\e[47m'
bgdefault='\e[49m'
bgcyan='\e[46m'
inverted='\e[7m'
bgyellow='\e[43m'

line='<==============================================================================>'
 
scriptloc=META-INF/com/google/android
aconfigloc=META-INF/com/google/android/aroma-config
coreusloc=/Working/META-INF/com/google/android/updater-script
uscriptloc=META-INF/com/google/android/updater-script
aromasorloc=META-INF/com/google/android/aroma
list_menu(){
	menuchoice=00
	#tree -di $1/ --noreport >$2 
	echo ''
	cd $1
	ls > $2
	loop=`wc -l < $2`
	echo -e "$cyan Number $endc     |     Path\n"
	echo ''
	for((i=1;i<=$loop;i++));
	do
		list=`echo -e "$cyan$i$endc   : :  " ;head -n $i $2 | tail -n 1`
		echo -e $list
	done
	while [ $menuchoice == 00 ]
	do
		echo -en "\n$red Enter choice $cyan [1-$loop] $endc $endc : "
		read menuchoice
		if [ $menuchoice -ge 1 ] && [ $menuchoice -le $loop ];then
			choice=`head -n $menuchoice $2 | tail -n 1`
			menuchoice=99
			#return $choice
		else	
			echo -e "\nWrong choice! Enter Again \n"
			menuchoice=00
		fi
	done
}
alert_window(){
	echo ''
	echo $line
	echo -en "\n$red Enter Alert Prompt Title $endc : ";read alert_title
	echo -en "\n$red Enter Alert Text $endc : ";read alert_text
	cat >> $aconfigloc <<EOF
##
# Alert Window
#

alert( "$alert_title", "$alert_text");

EOF

}
aroma_builder(){
	mkdir -p $scriptloc 2>/dev/null
	rm $aconfigloc 2>/dev/null
	touch $scriptloc/aroma-config 2>/dev/null
	echo ''
	echo $line
	echo -e "Writing initial Information to $yellow aroma-config $endc...\n"
	sleep 1;
	echo '# Fix Colorspace Issue' >> $aconfigloc
	echo 'ini_set("force_colorspace","rgba");'  >> $aconfigloc
	#echo -e "\t $uline ini_set("force_colorspace","rgba");"
	sleep 1
	echo -e "\n $bgblue Select Screen Resolution $endc \n"
	echo -e "\n$cyan 1. $endc LDPI \n$cyan 2. $endc MDPI \n$cyan 3. $endc HDPI \n$cyan 4. $endc XHDPI \n$cyan 5. $endc XXHDPI \n"
	echo -en "\n$red Enter choice $cyan [1-5] $endc $endc : "
	read sresol
	cat >> $aconfigloc <<EOF
##
# Screen Resolution
#	
ini_set("dp","$sresol");	
EOF
	echo ''
	echo $line
	sleep 1
	echo -e "\n $bgblue Initialization Information $endc \n"
	echo -en "$red Rom/Mod Name $endc : ";read rom_name
	echo -en "$red Rom/Mod Version $endc : ";read rom_version
	echo -en "$red Rom/Mod Author $endc : ";read rom_author
	echo -en "$red Device $endc : ";read rom_device
	echo -en "$red Rom/mod Date $endc : ";read rom_date
	cat >> $aconfigloc <<EOF
##
# Initializing Information
#
ini_set("rom_name",             "$rom_name ");
ini_set("rom_version",          "$rom_version");
ini_set("rom_author",           "$rom_author");
ini_set("rom_device",           "$rom_device");
ini_set("rom_date",             "$rom_date");
EOF
	echo ''
	echo $line
	sleep 1
	echo -e "\n $bgblue Add Simple Splash[s] / Animated Splash[a] /No Splash[n] ? $endc\n"
	echo -en "$red Enter Choice $cyan [a/s/n] $endc $endc : ";read splashchoice
	case $splashchoice in
		s|S)
			echo -e "\nRe/Place the Splash image at $yellow Working/$aromasorloc/SPLASH.png $endc \n" | pv -qL 15
			echo -e " with your SPLASH.png,Image Name Should be SPLASH.png" | pv -qL 15
			echo -e "$red";read -p "Press any key when done...";echo -e "$endc"
			echo -en "$red Enter no of MILLISECONDS you want the Splash Image to Stay $endc : ";read animtime
			cat >> $aconfigloc <<EOF
##
# Show Simple Splash
#
splash(
	#-- Eg:Duration 5000ms / 5 seconds
	$animtime,
	
	#-- <AROMA Resource Dir>/SPLASH.png
	"SPLASH"
);
EOF
		echo "";;
		a|A)
			echo -e "\nRe/Place your Animation images in " | pv -qL 15
			echo -e "                   $yellow Working/$aromasorloc/anim/<images> $endc \n" | pv -qL 15
			echo -e "$red";read -p "Press any key when done...";echo -e "$endc"
			echo -en "$red Enter no of time you want the animation to Loop $endc : ";read animloop
			echo -en "$red Enter no of MILLISECONDS you want AN Image to stay $endc : ";read animtime
			#animimageloop=`ls -l $aromasorloc/anim | wc -l `
			ls $aromasorloc/anim/ | xargs -n 1 basename >temp.txt
			sed -i 's/.png//g' temp.txt 2>/dev/null
			sed -i 's/.jpg//g' temp.txt 2>/dev/null
			echo "###Show Animated Splash" >> $aconfigloc
			echo "anisplash(" >> $aconfigloc
			echo -e "#-- Number Loop\n $animloop," >> $aconfigloc
			al=`wc -l < temp.txt`
				for((z=1;z<=al;z++))
				do
					animimg=`head -n $z temp.txt | tail -n 1`
					if [ $z -eq $al ] ; then
					cat >> $aconfigloc <<EOF
	"anim/$animimg", $animtime
EOF
					else
					cat >> $aconfigloc <<EOF
	"anim/$animimg", $animtime,
EOF
					fi
					
				done < temp.txt
			echo ");" >> $aconfigloc
			echo "";;
		*)echo "No Splash"
	esac
	echo ''
	echo $line
	sleep 1
	echo -e "Adding code to Show $bgblue Language Selection Window $endc...."
	echo ''
cat >> $aconfigloc <<EOF
##
# Font Selection
#

fontresload( "0", "ttf/Roboto-Regular.ttf;ttf/DroidSansArabic.ttf;ttf/DroidSansFallback.ttf;", "12" ); #-- Use sets of font (Font Family)

##
# SHOW LANGUAGE SELECTION
#

selectbox(
  #-- Title
    "Select Language",
  
  #-- Sub Title
    "Please select installer language that you want to use while Installing ROM",
  
  #-- Icon:
    "@default",
  
  #-- Will be saved in /tmp/aroma/lang.prop
    "lang.prop",
  
    "English",            "Welcome to Installer",                                        1,      #-- selected.0 = 1
    "Indonesian",         "Selamat datang di Installer",                                 0,      #-- selected.0 = 2
    "Espanol",            "Bienvenido al Instalador",                                    0,      #-- selected.0 = 3
    "Simplified Chinesse","欢迎到安装",                                                   0,      #-- selected.0 = 4
    "Arabic",             "مرحبا بكم في المثبت",                                         0,      #-- selected.0 = 5        
    "French",             "Bienvenue dans l'installateur",                               0,      #-- selected.0 = 6
    "Russian",            "Добро пожаловать в установщик",                               0,      #-- selected.0 = 7
	"Italian",            "Benvenuti Installer",                                         0,      #-- selected.0 = 8
	"Hebrew",             "ברוכים הבאים להתקנה",							    	     0,		 #-- selected.0 = 9
	"Germany",            "Willkommen bei Installer",									 0 		 #-- selected.0 = 10

);

##
# SET LANGUAGE & FONT FAMILY
#

if prop("lang.prop","selected.0")=="1" then
  loadlang("langs/en.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" ); #-- "0" = Small Font ( Look at Fonts & UNICODE Demo Below )
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" ); #-- "1" = Big Font
endif;

if prop("lang.prop","selected.0")=="2" then
  loadlang("langs/id.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="3" then
  loadlang("langs/es.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="4" then
  loadlang("langs/cn.lang");
  fontresload( "0", "ttf/DroidSansFallback.ttf;ttf/Roboto-Regular.ttf", "12" ); 
  fontresload( "1", "ttf/DroidSansFallback.ttf;ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="5" then
  loadlang("langs/ar.lang");
  fontresload( "0", "ttf/DroidSansArabic.ttf;ttf/Roboto-Regular.ttf", "12" ); 
  fontresload( "1", "ttf/DroidSansArabic.ttf;ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="6" then
  loadlang("langs/fr.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="7" then
  loadlang("langs/ru.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="8" then
  loadlang("langs/it.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="9" then
  loadlang("langs/he.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

if prop("lang.prop","selected.0")=="10" then
  loadlang("langs/de.lang");
  fontresload( "0", "ttf/Roboto-Regular.ttf", "12" );
  fontresload( "1", "ttf/Roboto-Regular.ttf", "18" );
endif;

EOF
	echo ''
	echo $line
	sleep 1
	echo -e "\n $bgblue Theme Selection $endc \n"
	echo -e "\n$cyan 1. $endc Add a Theme Selection Window\n$cyan 2. $endc Just use any one theme (No user choice)"
	echo -e "$cyan 3. $endc Use Default Generic Theme \n"
	echo -en "$red Enter Choice $cyan [1-3] $endc $endc : "
	read themechoice
		case $themechoice in
		1)echo -e "\nTheme Selection Window Added"
		cat >> $aconfigloc <<EOF
		##
#   SELECT THEME
#

selectbox(
  #-- Title
    "<~themes.title>",
  
  #-- Sub Title
    "<~themes.desc>",
  
  #-- Icon:
    "@personalize",
  
  #-- Will be saved in /tmp/aroma/theme.prop
    "theme.prop",
  
    "Generic",            "Unthemed AROMA Installer",                                    0,      #-- selected.0 = 1
    "MIUI Theme",         "MIUI Theme by mickey-r & amarullz",                           0,      #-- selected.0 = 2
    "NXT Theme",          "NXT Theme by Pranav Pandey",                                  0,      #-- selected.0 = 3
    "NextGen Theme",      "NextGen Theme by amarullz edit by Ayush",                     0,      #-- selected.0 = 4
    "Sense Theme",        "HTC Sense Theme by amarullz",                                 0,      #-- selected.0 = 5
    "Honami Theme",       "Xperia i1 Theme by Ayush",                                    1       #-- selected.1 = 6

);

##
# SET THEME
#

if prop("theme.prop","selected.0")=="2" then
  theme("miui");
endif;

if prop("theme.prop","selected.0")=="3" then
  theme("xNXT");
endif;

if prop("theme.prop","selected.0")=="4" then
  theme("NextGen");
endif;

if prop("theme.prop","selected.0")=="5" then
  theme("sense");
endif;

if prop("theme.prop","selected.0")=="6" then
  theme("i1");
endif;


EOF
			echo '';;
		2)
			origpath=`pwd`
			list_menu META-INF/com/google/android/aroma/themes /tmp/theme.txt
			cd $origpath
			echo -e "\n$yellow $choice $endc Theme Selected"
			cat >> $aconfigloc <<EOF
##
# SET THEME
#			
	theme("$choice");
EOF
			echo'';;
		*)
		echo "Generic Theme Added."
		echo '';;
		esac
	echo $line
	echo -e "\nAdding code to Show $bgblue Welcome Window - Rom/mod Info $endc...."
	cat >> $aconfigloc <<EOF
##
#   SHOW ROM/Mod INFORMATION
#

viewbox(
  #-- Title
    "<~welcome.title>",
  
  #-- Text
    "<~welcome.text1> <b>"+
	  #-- Get Config Value
	  ini_get("rom_name")+
	"</b> <~common.for> <b>"+ini_get("rom_device")+"</b>.\n\n"+
    
    "<~welcome.text2>\n\n"+
	
      "  <~welcome.version>\t: <b><#selectbg_g>"+ini_get("rom_version")+"</#></b>\n"+
	  "  <~welcome.updated>\t: <b><#selectbg_g>"+ini_get("rom_date")+"</#></b>\n\n\n"+

    "<~welcome.next>",
  
  #-- Icon
    "@welcome"
);
EOF
	
	echo ''	
	echo $line
	sleep 2
	echo ''
	echo -e "$bgblue License Window $endc\n"
	echo -e "Do you want to include a License Window? $cyan [ y = yes/ n =no ] $endc"
	echo -en "\n$red Enter choice $cyan [y/n] $endc$endc : ";read licensechoice
	case $licensechoice in
		y|Y)
			echo -e "\nEdit the License file at " | pv -qL 15
			echo -e "                     $yellow $aromasorloc/license.txt $endc\n" | pv -qL 15
			echo -e "$red";read -p "Press any key when done...";echo -e "$endc"
			cat >> $aconfigloc <<EOF
##
# LICENSE
#

agreebox(
  #-- Title
    "$rom_name T&C",
  
  #-- Subtitle / Description
    "Read Carefully",
  
  #-- Icon:
    "@license",
  
  #-- Text Content 
    resread("license.txt"),
  
  #-- Checkbox Text
    "Do you agree??",
  
  #-- Unchecked Alert Message
    "Can't Proceed till you Agree!!"
);
			
EOF
		echo ''
		;;
	*)echo ''
	echo $line
	sleep 1
	esac
		
}
menu_box(){
	echo ''	
	echo $line
	echo -e "This Option Adds the following to the Menu Box \n" | pv -qL 15
	sleep 1
	spccolor="$bgcyan $endc"
	echo -e "$bgcyan                                                                              $endc"
echo -e "$spccolor#------------+-------------[ Menubox Items ]---------------+---------------#$spccolor"
echo -e "$spccolor# TITLE      |                SUBTITLE                     |   Item Icons  #$spccolor"
echo -e "$spccolor#------------+---------------------------------------------+---------------#$spccolor";
echo -e "$spccolor#(o) $rom_name Installation,                                        #$spccolor";
echo -e "$spccolor#      ROM Installation with Various Features - RECOMMENDED                #$spccolor";
echo -e "$spccolor#(o) System Info,                                                          #$spccolor";
echo -e "$spccolor#      Get and show device/partition informations,                         #$spccolor";
echo -e "$spccolor#(o) ChangeLog,                                                            #$spccolor";
echo -e "$spccolor#      ROM/Mod ChangeLog,                                                  #$spccolor";
echo -e "$spccolor#(o) Quit Install,                                                         #$spccolor";
echo -e "$spccolor#      Quit Install,                                                       #$spccolor";
echo -e "$spccolor#--------------------------------------------------------------------------#$spccolor"
echo -e "$bgcyan                                                                              $endc"
	echo ''
	echo $line
	sleep 2
	echo -e "\n$yellow $rom_name Installation $endc and $yellow Quit Install $endc" | pv -qL 15
	echo -e "                                     are included by default" | pv -qL 15
	echo -e "\nWant to Add $yellow System Info and Changelog $endc as well? "
	echo -e "$cyan y $endc = Yes,Add the two options \n$cyan n $endc = NO,dont Add."
	echo -en "\n$red Enter choice $cyan [y/n] $endc$endc : ";read boxch
	case $boxch in
		y|Y)echo -en "\n$red Enter Model No:$endc : ";read rom_model
			echo -en "$red Enter Manufacturer:$endc : ";read rom_manufacturer
			echo -e "\nAdding Entire Menubox..."
			cat >> $aconfigloc <<EOF

##
# MAIN MENU- INSTALLER n MISC
#
menubox(
  #-- Title
    "$rom_name™ Menu",
  
  #-- Sub Title
    "Please select from the Menu Below to Modify the required features",
  
  #-- Icon
    "@apps",
    
  #-- Will be saved in /tmp/aroma/menu.prop
    "menu.prop",
    
     #------------+-------------[ Menubox Items ]---------------+---------------#
     # TITLE      |                SUBTITLE                     |   Item Icons  #
     #------------+---------------------------------------------+---------------#	
	 
	"$rom_name Installation", "ROM Installation with Various Features - RECOMMENDED","@install",      #-- selected = 1
    "System Info",         "Get and show device/partition informations",          "@info",         #-- selected = 2
    "ChangeLog",           "ROM/Mod ChangeLog",                                   "@agreement",    #-- selected = 3
    "Quit Install",        "Quit Install",                                       "@install"       #-- selected = 4

);

##
# System Info 
#

if prop("menu.prop","selected")=="2" then

  #-- Show Please Wait
  pleasewait("Getting System Information...");

  #-- Fetch System Information
  setvar(
    #-- Variable Name
      "sysinfo",
    
    #-- Variable Value
      "<@center><b>Your Device System Information</b></@>\n\n"+
      
      "Device Name\t\t: <#469>$rom_device</#>\n"+
      "Board Name\t\t: <#469>$rom_model</#>\n"+
      "Manufacturer\t\t: <#469>$rom_manufacturer</#>\n"+
	  
	  "\n"+
	  
      "System Size\t\t: <b><#selectbg_g>"+getdisksize("/system","m")+" MB</#></b>\n"+
        "\tFree\t\t: <b><#selectbg_g>"+getdiskfree("/system","m")+" MB</#></b>\n\n"+
      "Data Size\t\t: <b><#selectbg_g>"+getdisksize("/data","m")+" MB</#></b>\n"+
        "\tFree\t\t: <b><#selectbg_g>"+getdiskfree("/data","m")+" MB</#></b>\n\n"+
      "SDCard Size\t\t: <b><#selectbg_g>"+getdisksize("/sdcard","m")+" MB</#></b>\n"+
        "\tFree\t\t: <b><#selectbg_g>"+getdiskfree("/sdcard","m")+" MB</#></b>\n\n"+

      ""
  );
  
  #-- Show Textbox
  textbox(
    #-- Title
      "System Information",
    
    #-- Subtitle
      "Current system Information on your $rom_device",
    
    #-- Icon
      "@info",
    
    #-- Text
      getvar("sysinfo")
  );
 #-- Back to Menu ( 2 Wizard UI to Back )
 back("2");
  
endif;
##
# CHANGELOG DISPLAY
#

if prop("menu.prop","selected")=="3" then

    #-- TextDialog 
 textdialog(
    #-- Title
    "YOUR ROM NAME Changelog",
	#-- Text
    resread("changelog.txt"),
    #-- Custom OK Button Text (Optional)
    "Close"
 );
 
  #-- Back to Menu ( 2 Wizard UI to Back )
  back("1");
  
endif;

##
# QUIT INSTALLER
#

if prop("menu.prop","selected")=="4" then

#-- Exit
	if
	  confirm(
		#-- Title
		  "Exit",
		#-- Text
		  "Are you sure want to exit the Installer?",
		#-- Icon (Optional)
		  "@alert"
	  )=="yes"
	then
	  #-- Exit 
	  exit("");
	endif;

endif;

EOF
		echo '';;
		*)
		echo -e "\nAdding only $yellow $rom_name Installation $endc and $yellow Quit Install ...$endc"
		cat >> $aconfigloc <<EOF
##
# MAIN MENU- INSTALLER n MISC
#
menubox(
  #-- Title
    "$rom_name Menu",
  
  #-- Sub Title
    "Please select from the Menu Below to Modify the required features",
  
  #-- Icon
    "@apps",
    
  #-- Will be saved in /tmp/aroma/menu.prop
    "menu.prop",
    
     #------------+-------------[ Menubox Items ]---------------+---------------#
     # TITLE      |                SUBTITLE                     |   Item Icons  #
     #------------+---------------------------------------------+---------------#
	 
	"$rom_name Installation", "ROM Installation with Various Features - RECOMMENDED",  "@install",#--selected=1
    "Quit Install",       "Quit Install",     "@install"       #-- selected = 4

);
##
# QUIT INSTALLER
#

if prop("menu.prop","selected")=="4" then

#-- Exit
	if
	  confirm(
		#-- Title
		  "Exit",
		#-- Text
		  "Are you sure want to exit the Installer?",
		#-- Icon (Optional)
		  "@alert"
	  )=="yes"
	then
	  #-- Exit 
	  exit("");
	endif;

endif;

EOF
			echo '';;
	esac	
}

select_box(){
	echo -en "\n$red Enter $cyan No $endc$red of Groups You want to Add in SelectBox $endc$cyan$i$endc : $endc ";read selbox_grp_cnt
	mkdir /tmp/select 2>/dev/null ;
	for((g=1;g<=$selbox_grp_cnt;g++))
	do	
		defflag=0
		defaultch=0
		echo -en "\n$red Enter Group $cyan $g $endc $red title $endc : ";read header[$i][$g]
			#echo "${header[$i][$g]}" 
			grpname="${header[$i][$g]}"
			gname=`echo "$grpname" | sed 's/ //g'`
			#echo "$gname";
			#rm /tmp/${header[$i][$g]} 2>/dev/null
			touch /tmp/select/$gname 2>/dev/null;
			cat >> $aconfigloc <<EOF
		"${header[$i][$g]}",    	"",					2,         #-- Group $g. key = "selected.$g"
EOF
			echo ""
			echo $line
			echo -e "$bgblue Group ${header[$i][$g]} : $endc"
			echo -en "\n$red Enter $cyan No $endc$red of options you want in Group $endc$green${header[$i][$g]} $endc$endc :   ";read grp_opt_cnt;
			for((o=1;o<=$grp_opt_cnt;o++))
			do
				echo ''
				echo "                             ---------------"
				echo -en "\n$red Enter $default Title $endc$red for Option$endc $cyan$o$endc$red in Group $endc$green${header[$i][$g]} $endc$endc : ";read option				
				echo -en "$red Enter $default Description $endc$red for Option $endc$cyan$option$endc $endc$endc : ";read odescrip	
				if [ "$defflag" -eq 0 ]; then
				echo -e "\n$red Keep Option $endc$cyan$option$endc $red Default Selected? $endc$cyan[1=yes / 0=No]$endc\n ";
				echo -en "$red Enter Choice $cyan [1/0] $endc$endc : ";
				read defaultch;
					if [ "$defaultch" -eq 1 ]; then defflag=1;fi
				else
					defflg=1
					defaultch=0
				fi	
				cat >> /tmp/select/$gname <<EOF
$option , file_getprop("/tmp/aroma/window$i.prop","selected.$g") == "$o"
EOF

				
				if [ "$o" -eq "$grp_opt_cnt" ] && [ "$g" -eq "$selbox_grp_cnt" ] ; then
					cat >> $aconfigloc <<EOF
			"$option",			"$odescrip",              $defaultch  #-- selected.$g = $o
EOF
				else
					cat >> $aconfigloc <<EOF
			"$option",			"$odescrip",              $defaultch, #-- selected.$g = $o
EOF
				fi
				#echo "$odescrip" >> /tmp/${header[$i][$g]};
			done
			echo -e "" >> $aconfigloc
			echo ''
			echo $line
	done
}

check_box(){
	echo -en "\n$red Enter $cyan No $endc$red of Groups You want to Add in CheckBox $endc$cyan$i$endc : $endc ";read selbox_grp_cnt
	mkdir /tmp/select 2>/dev/null 
	for((g=1;g<=$selbox_grp_cnt;g++))
	do	
		echo -en "\n$red Enter Group $cyan $g $endc $red title $endc : ";read header[$i][$g]
			grpname="${header[$i][$g]}"
			gname=`echo "$grpname" | sed 's/ //g'`
			#rm /tmp/${header[$i][$g]} 2>/dev/null
			touch /tmp/select/$gname 2>/dev/null 
			cat >> $aconfigloc <<EOF
		"${header[$i][$g]}",    	"",					2,         #-- Group $g
EOF
			echo ""
			echo $line
			echo -e "$bgblue Group ${header[$i][$g]} : $endc"
			echo -en "\n$red Enter $cyan No $endc$red of options you want in Group $endc$green${header[$i][$g]} $endc$endc :   ";read grp_opt_cnt;
			for((o=1;o<=$grp_opt_cnt;o++))
			do
				echo ''
				echo "                             ---------------"
				echo -en "\n$red Enter $default Title $endc$red for Option$endc $cyan$o$endc$red in Group $endc$green${header[$i][$g]} $endc$endc : ";read option				
				echo -en "$red Enter $default Description $endc$red for Option $endc$cyan$option$endc $endc$endc : ";read odescrip	
				echo -e "\n$red Keep Option $endc$cyan$option$endc $red Default Selected? $endc$cyan[1=yes / 0=No]$endc\n ";
				echo -en "$red Enter Choice $cyan [1/0] $endc$endc : ";
				read defaultch;
				cat >> /tmp/select/$gname <<EOF
$option , file_getprop("/tmp/aroma/checkbox$i.prop","item.$g.$o") == "1"
EOF

				if [ "$o" -eq "$grp_opt_cnt" ] && [ "$g" -eq "$selbox_grp_cnt" ] ; then
					cat >> $aconfigloc <<EOF
			"$option",			"$odescrip",              $defaultch  #-- item.$g.$o
EOF
				else
					cat >> $aconfigloc <<EOF
			"$option",			"$odescrip",              $defaultch, #-- item.$g.$o
EOF
				fi
				
			done
			echo -e "" >> $aconfigloc
			echo ''
			echo $line
	done
}

build_menu(){
	cd /Working
	menuchoice=0
	rm list.txt 2>/dev/null
	tree -dfi $1/ --noreport >list.txt -P */app/
	loop=`wc -l < list.txt`
	echo -e '<==============================================================================>';
	echo "                           Choose Directory to Push  ";
	echo -e '<==============================================================================>\n'
	echo -e "$cyan Path Number $endc  | |   Path"
	for((i=1;i<=$loop;i++));
	do
			list=`echo -e "$cyan$i$endc       : :  " ;head -n $i list.txt | tail -n 1`
		echo -e $list
	done
	cd /tmp/select
	#read -p "WAit"
}
uscript_fun(){
	rm $uscriptloc 2>/dev/null
	touch /Working/$uscriptloc
	echo ''
	echo $line
	echo ''
	echo -e "Adding initial code to updater-script...."
		cat >> $uscriptloc <<EOF
################################ UPDATER SCRIPT #####################################
##############################Created by Lazy Aroma##################################
ui_print("-> Initialising....");
ui_print("-> Please Wait....");



if
    file_getprop("/tmp/aroma-data/menu.prop","selected") == "1"
     then

		ui_print("-> Installing $rom_name ");
		
EOF
	echo -en "\n$red Add code to Mount $cyan /system [y/n] $endc ? $endc : ";read sysmountch
	case $sysmountch in
		n|N)
		echo '';;
		*)	echo 'ui_print("-> Mounting System...");' >> $coreusloc
			echo 'run_program("/sbin/busybox", "mount", "/system");' >> $coreusloc;;
	esac
	echo -en "\n$red Add code to Mount $cyan /data [y/n] $endc ? $endc : ";read sysmountch
	case $sysmountch in
		n|N)
		echo '';;
		*)	echo 'ui_print("-> Mounting Data...");' >> $coreusloc
			echo 'run_program("/sbin/busybox", "mount", "/data");' >> $coreusloc;;
	esac
	echo -en "\n$red Add code to Mount $cyan /sdcard [y/n] $endc ? $endc : ";read sysmountch
	case $sysmountch in
		n|N)
		echo '';;
		*)	echo 'ui_print("-> Mounting SYSTEM...");' >> $coreusloc
			echo 'run_program("/sbin/busybox", "mount", "/sdcard");' >> $coreusloc;;
	esac
	if [ -d [s]ystem ];then 
	echo "" >> $coreusloc
	echo 'ui_print("-> Extracting System...");'	>> $coreusloc
	echo 'package_extract_dir("system", "/system");' >> $coreusloc
	echo "" >> $coreusloc
	fi
	if [ -d [d]ata ];then 
	echo "" >> $coreusloc
	echo 'ui_print("-> Extracting Data...");'	>> $coreusloc
	echo 'package_extract_dir("data", "/data");' >> $coreusloc
	echo "" >> $coreusloc
	fi
	echo -e "\n$line\n"
	echo "Now you will be shown the options that you have created in" | pv -qL 25
	echo -e "                                         the Aroma GUI Window/s \n" | pv -qL 15
	echo "Select what happens when an option is selected by user..." | pv -qL 25
	
	
 
	cd /tmp/select
	for file in ./*
	do
		fle=`echo ${file##*/}`
		echo $fle
		echo ''
		echo -e "$line"
		echo ''
		echo -e "$bgblue Group $fle $endc\n"
		line_cnt=`wc -l < ${fle}`
		
			for((l=1;l<=$line_cnt;l++));
			do
				lne=`head -n $l $fle | tail -n 1`
				part1=`echo "${lne%%,*}"`
				part2=`echo "${lne#*,}"`
				sleep 2
				echo -e "\n$line\n"
				echo -e "What do you want to do when $bgyellow $part1 $endc is selected? $endcn : \n"
				echo -e "$cyan 1. $endc Push files from $green $adirname $endc to the $green phone $endc "
				echo -e "$cyan 2. $endc Write a custom $green Edify $endc command by self.\n "
				echo -en "$red Enter Choice $cyan [1-2] $endc : "; read whatdo
				case $whatdo in
				1)
				
				build_menu $adirname
				menuchoice=0
				errorflag=0
				echo -e "\n$line\n$red From which directory do you want to Push/Install when $green$part1$endc$red is selected? $endcn\n"
				while [ "$errorflag" -eq 0 ]
				do
					echo -en "$red Enter Choice $cyan [1-$loop] $endc$endc : ";read pushsrcch
					if [ "$pushsrcch" -ge 1 ] && [ "$pushsrcch" -le $loop ];then
						yo=`head -n $pushsrcch /Working/list.txt | tail -n 1`
						echo -en "\nYou have chosen: $green $yo $endc \n"
						errorflag=1;
						else
						echo -e "\n$pushsrcch isn't a valid choice. Valid Choice ==> $cyan [1-$loop] $endc <== \n"
						errorflag=0
					fi
				done
				echo -e "\n$line\n"
				echo -e "$bgblue Where to Push/Install $endc\n"
				echo -e "$cyan 1. $endc To $green /system $endc "
				echo -e "$cyan 2. $endc To $green /data $endc "
				echo -e "$cyan 3. $endc To $green /sdcard $endc "
				echo -e "$cyan 4. $endc To $green custom/other path $endc\n "
				echo -en "$red Enter Choice $cyan [1-4] $endc : ";read pushdestch
				
				case $pushdestch in
				1)yo1="/system";;
				2)yo1="/data";;
				3)yo1="/sdcard";;
				*)echo -en "\n$red Enter Custom Path or just ENTER for nothing: $endc";read yo1;;
				esac
			cat >> $coreusloc <<EOF
		
	if
	$part2
	then
	ui->print(" Installing $part1 ");
	package_extract_dir("$yo", "$yo1");
	endif;
		
EOF
			echo '';;	
				
			*)
			echo -e "\n $line \n"
			echo -e "$bgblue Group $fle $endc\n"
			echo "Enter the Edify command and the ';' as well : ";read edifycmd
			cat >> $coreusloc <<EOF
		
	if
	$part2
	then
	ui->print(" Installing $part1 ");
	$edifycmd
	endif;
		
EOF
			echo '';;
		esac	
	
			done
	done
	echo -e "\n$line\n"
	cd /Working
	echo -en "\n$red Add code to $cyan Fix-Permisions [y/n] $endc $red (Useful for Roms) ? $endc : ";read xtrach
	if [ $xtrach == y ];then
	cp /bin/files/fix_permissions /Working/
		cat >> $uscriptloc <<EOF
	
ui_print("-> Fixing Permissions :P");
package_extract_file("fix_permissions", "/tmp/fix_permissions");
set_perm(0, 0, 0777, "/tmp/fix_permissions");
run_program("/tmp/fix_permissions");

EOF
	else
	echo ''
	fi
		
	echo -en "\n$red Add code to $cyan Symlink [y/n] $endc $red (Useful for Roms) ? $endc : ";read xtrach
	if [ $xtrach == y ];then
		cat >> $uscriptloc <<EOF
	
ui_print("-> Making symlinks...");
symlink("toolbox", "/system/bin/start");
symlink("toolbox", "/system/bin/lsmod");
symlink("toolbox", "/system/bin/r");
symlink("toolbox", "/system/bin/vmstat");
symlink("toolbox", "/system/bin/ifconfig");
symlink("toolbox", "/system/bin/ionice");
symlink("toolbox", "/system/bin/schedtop");
symlink("toolbox", "/system/bin/wipe");
symlink("toolbox", "/system/bin/reboot1");
symlink("toolbox", "/system/bin/rmdir");
symlink("toolbox", "/system/bin/route");
symlink("toolbox", "/system/bin/chown");
symlink("toolbox", "/system/bin/lsof");
symlink("toolbox", "/system/bin/getevent");
symlink("toolbox", "/system/bin/mkdir");
symlink("toolbox", "/system/bin/netstat");
symlink("toolbox", "/system/bin/renice");
symlink("toolbox", "/system/bin/uptime");
symlink("mksh", "/system/bin/sh");
symlink("toolbox", "/system/bin/smd");
symlink("toolbox", "/system/bin/sync");
symlink("toolbox", "/system/bin/mount");
symlink("toolbox", "/system/bin/printenv");
symlink("toolbox", "/system/bin/top");
symlink("toolbox", "/system/bin/log");
symlink("toolbox", "/system/bin/sendevent");
symlink("toolbox", "/system/bin/ps");
symlink("toolbox", "/system/bin/dmesg");
symlink("toolbox", "/system/bin/umount");
symlink("toolbox", "/system/bin/kill");
symlink("toolbox", "/system/bin/stop");
symlink("toolbox", "/system/bin/newfs_msdos");
symlink("toolbox", "/system/bin/iftop");
symlink("toolbox", "/system/bin/chmod");
symlink("toolbox", "/system/bin/rmmod");
symlink("toolbox", "/system/bin/setconsole");
symlink("toolbox", "/system/bin/mv");
symlink("toolbox", "/system/bin/rm");
symlink("toolbox", "/system/bin/id");
symlink("toolbox", "/system/bin/watchprops");
symlink("toolbox", "/system/bin/hd");
symlink("toolbox", "/system/bin/ctrlaltdel");
symlink("toolbox", "/system/bin/sleep");
symlink("toolbox", "/system/bin/ls");
symlink("toolbox", "/system/bin/cmp");
symlink("toolbox", "/system/bin/insmod");
symlink("toolbox", "/system/bin/nandread");
symlink("toolbox", "/system/bin/date");
symlink("toolbox", "/system/bin/dd");
symlink("toolbox", "/system/bin/getprop");
symlink("toolbox", "/system/bin/cat");
symlink("toolbox", "/system/bin/df");
symlink("toolbox", "/system/bin/touch");
symlink("toolbox", "/system/bin/ioctl");
symlink("toolbox", "/system/bin/setprop");
symlink("toolbox", "/system/bin/notify");
symlink("toolbox", "/system/bin/ln");

EOF
	else
	echo ''
	fi
cat >> $uscriptloc <<EOF

ui_print("-> Finished Installation...!");
ui_print("-> Enjoy...");
ui_print("-> ...");
ui_print("-> Done....");

endif;

run_program("/sbin/busybox", "umount", "/system");
run_program("/sbin/busybox", "umount", "/data);
show_progress(1, 0);

EOF
}


tool_menu(){
	echo ""
	echo $line
	cat /bin/text
	echo $line
	echo -e "\n$cyan 1. $endc Build Initial Aroma Windows [Welcome Screen,Animation etc]"
	echo -e "$cyan 2. $endc Build Main Menu Box \n$cyan 3. $endc Add Alert Window"
	echo -e "$cyan 4. $endc Create SelectBox Window/s [One Choice Windows] \n$cyan 5. $endc Create CheckBox Window/s [Multiple Choice Windows]"
	echo -e "$cyan 6. $endc Add Pre-Install Window\n$cyan 7. $endc Add Installation GUI Window\n\n$cyan 8. $endc Create Updater-Script"
	echo -e "$cyan 9. $endc Zip the Project \n$cyan 10. $endc Exit! "
	echo -en "\n$red Enter choice $cyan [1-10] $endc$endc : ";read mainch
	case $mainch in
		1)	aroma_builder
			echo -e "\n Basic Window Setup Complete.\n" | pv -qL 15
			echo $line
			sleep 2
			#echo -e "\nContinue with building menu box ? \n$cyan y $endc =yes \n$cyan n $endc = No,Return to main Menu"
			clear
			tool_menu
			;;
		
		2)	menu_box
			echo -e "\n Main Menu Box Complete.\n" | pv -qL 15
			echo $line
			sleep 2
			clear
			tool_menu
			echo '';;
		3)	alert_window
			echo -e "\n Alert Prompt Complete.\n" | pv -qL 15
			echo $line
			sleep 2
			clear
			tool_menu;;
			
		4)	cat >> $aconfigloc <<EOF
##
#  Select Type of Install
#

if prop("menu.prop","selected")=="1" then		
EOF
		
			echo -en "\n$red Enter the $cyan No $endc $red of $endc $magenta Selectbox windows $endc $red you want:$endc : ";read selbox_cnt
			for((i=1;i<=$selbox_cnt;i++));
			do
				echo $line
				echo -e "                            $magenta Select Box $i $endc              "
				echo ''
				echo $line
				echo -en "\n$red Enter $magenta Selectbox $endc $cyan$i$endc $default Title $endc : ";read selbox_title
				echo -en "\n$red Enter $magenta Selectbox $endc $cyan$i$endc $default Sub-Title $endc : ";read selbox_subtitle
				cat >> $aconfigloc <<EOF
##
# Sub Window $i
#

selectbox(
  #-- Title
    "$selbox_title",
  
  #-- Sub Title
    "$selbox_subtitle",
  
  #-- Icon:
     "icons/install",
	 
  #-- Will be saved in /tmp/aroma/window$i.prop
    "window$i.prop",
  
	  #----------------------------------[ Selectbox With Groups ]-----------------------------------#
	  # TITLE            |  SUBTITLE                                                 | Initial Value #
	  #------------------+-----------------------------------------------------------+---------------#  
	  
EOF
				
			select_box
			echo -e "" >> $aconfigloc
			echo "#--------[ Initial Value = 0: Unselected, 1: Selected, 2: Group Item, 3: Not Visible ]---------# "	>> $aconfigloc	
			echo " ); " >> $aconfigloc
			echo "$i Select Boxe/s Added. " | pv -qL 15
			clear
			tool_menu
			done;;
		
		5)	echo -en "\n$red Enter the $cyan No $endc $red of $endc $magenta Checkbox windows $endc $red you want:$endc : ";read selbox_cnt
			for((i=1;i<=$selbox_cnt;i++));
			do
				echo $line
				echo -e "                            $magenta Check Box $i $endc              "
				echo ''
				echo $line
				echo -en "\n$red Enter $magenta Checkbox $endc $cyan$i$endc $default Title $endc : ";read selbox_title
				echo -en "\n$red Enter $magenta Checkbox $endc $cyan$i$endc $default Sub-Title $endc : ";read selbox_subtitle
				cat >> $aconfigloc <<EOF
##
# Sub Window $i with Checkboxes
#

checkbox(
  #-- Title
    "$selbox_title",
  
  #-- Sub Title
    "$selbox_subtitle",
  
  #-- Icon:
     "@update",
	 
  #-- Will be saved in /tmp/aroma/checkbox$i.prop
    "checkbox$i.prop",
  
	  #----------------------------------[ Selectbox With Groups ]-----------------------------------#
	  # TITLE            |  SUBTITLE                                                 | Initial Value #
	  #------------------+-----------------------------------------------------------+---------------#
	  
EOF
				
			check_box
			echo -e "" >> $aconfigloc
			echo "#--------[ Initial Value = 0: Unselected, 1: Selected, 2: Group Item, 3: Not Visible ]---------# "	>> $aconfigloc	
			echo " ); " >> $aconfigloc
			echo "$i Check Boxe/s Added. " | pv -qL 15
			sleep 2
			clear
			tool_menu
			done;;
		6)
			echo ''
			echo $line
			sleep 2
			echo -e "Adding code to Show $bgblue Pre-Install Window $endc...."
			echo ''
			cat >> $aconfigloc <<EOF

# Installation UI

ini_set("text_next", "Install Now");
ini_set("icon_next", "@installbutton");
  
viewbox(
  #-- Title
    "Ready to Install",

  #-- Text
    "ROM is ready to be installed.\n\n"+
	"Press <b>Install ROM</b> to begin the installation.\n\n"+
	"To review or change any of your installation settings, press <b>Back</b>.\n\n"+
	"Press Menu -> Quit Installation to quit.",

  #-- Icon
    "@install"
);
endif;

EOF
			echo''
			echo " Pre-Installation Window Added.. " | pv -qL 15
			sleep 2
			clear
			tool_menu
			;;
		7)  echo ''
			echo $line
			sleep 1
			echo -e "Adding code to Show $bgblue Installation GUI Window $endc...."
			echo ''
			cat >> $aconfigloc <<EOF
##
# INSTALLATION PROCESS
#

if prop("menu.prop","selected")== "1" 
then

ini_set("text_next", "Next");
ini_set("icon_next", "@next");

install(
  "YOUR $rom_name™ Installation",
  getvar("rom_name") + "\n" +
  "Please wait while this ROM blows up your device :P" +
  "",
  "icons/install"
);

ini_set("text_next", "Finish");
ini_set("icon_next", "@finish");

checkviewbox(
  #-- Title
    "Installation Completed",
	
  #-- Text
    "<#selectbg_g><b>Congrats...</b></#>\n\n"+
    "<b>"+ini_get("rom_name")+"</b> has been installed into your device.\n\n",
    
#-- Icon
    "@welcome",

  #-- Checkbox Text
    "Reboot your device now.",

  #-- Initial Checkbox value ( 0=unchecked, 1=checked ) -  (Optional, default:0)
    "1",

  #-- Save checked value in variable "reboot_it" (Optional)
    "reboot_it"
);
endif;

###
# Check if reboot checkbox was checked

if
  getvar("reboot_it")=="1"
then
  #
  # reboot("onfinish");   - Reboot if anything finished
  # reboot("now");        - Reboot Directly
  # reboot("disable");    - If you set reboot("onfinish") before, use this command to revert it.
  #
  reboot("onfinish");
endif;

EOF
			echo " Installation GUI Window Added.. " | pv -qL 15
			sleep 2
			clear
			tool_menu
			;;			
		8)	echo ''
			echo $line
			echo ''
			echo -en "\n$red Enter the name of your directory which contains Aroma Customization Apps [Case sensitive] $endc : ";read adirname
			uscript_fun
			echo ''
			echo -e " Created updater-script and aroma-config. Find it at $yellow /Working/$uscriptloc $endc " | pv -qL 15
			sleep 2
			tool_menu
			;;
		9)
			echo ''
			echo $line
			echo ''
			echo -en "\n$red Enter the name of the Zip you want $endc : ";read zipname
			echo ''
			rm *.txt 2>/dev/null
			7za a -tzip -mx5 "$zipname" * 
			mkdir /Output 2>/dev/null
			mv $zipname /Output/ 2>/dev/null
			mv $zipname.zip /Output/ 2>/dev/null
			echo -e "\n\n Created $magenta $zipname $endc Find it at $yellow /Output ... $endc \n" | pv -qL 15
			sleep 2
			clear
			tool_menu
			;;
		10)	echo ''
			echo "$line"
			echo -e "$magenta Script by Maddy... $endc\n" | pv -qL 20
			echo -e "                    $magenta Do leave a Feedback and Thank... $endc\n" | pv -qL 20
			echo -e "                                                      $magenta Bye... $endc\n" | pv -qL 20
			sleep 3
			echo -e "$line\n"
			rm -rf /tmp/* 2>dev/null
			exit 0;
			;;
		*)echo ''
		echo -en "\n$yellow Not a Valid Option ! $endc : "
		sleep 2
		clear
		tool_menu
		;;
	esac	
}
#echo -e "\n Welcome to $magenta Lazy Aroma $endc\n" | pv -qL 5
echo ""
echo $line
cat /bin/text | pv -qL 35
echo $line
sleep 2
echo ''	
clear
cp -r /bin/files/META-INF /Working/
cp -rf /Your_updater-binary_here/update-binary /Working/META-INF/com/google/android/update-binary-installer 2>/dev/null
tool_menu
rm *.txt 2>/dev/null
#read -p "Done!"
#7za -tzip -mx5 name *

