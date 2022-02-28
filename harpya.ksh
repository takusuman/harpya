#!/bin/ksh

program="$0"
ver='2022-02-27'

function main { 
	while getopts ":N:E:s:l:" option; do
		case "$option" in
			N) typeset -r producer_name="$OPTARG" ;;
			E) typeset -r federative_unit="$OPTARG" ;;
			s) s="$OPTARG" ;;
			l) base_URL="${OPTARG}" ;;
		esac
	done

	base_URL=${base_URL:-https://sad.ancine.gov.br/projetosaudiovisuais/ConsultaProjetosAudiovisuais.do?method=consultarProjetos&offset=}

	# Possivelmente esse nome de diretório não é seguro para o UNIX, então é
	# bom nos certificarmos de que sempre estaremos usando essa variável de
	# forma agrupada, para evitar quebras por espaços.
	run_time=$(date +%Y-%m-%d-%H.%M.%S)
	working_directory="${PWD}/${producer_name}_${run_time}"
	blackbox_file="${PWD}/${producer_name}_${run_time}.log.txt"
	
harpya_logo="
                    ., .'     
           ' ''  .:c;c:;'..   
          kkxxxkOdkd''.,'..   
         'OkdxxdOdxl;'''..    
      ..;Ol,;;llklkOldcc;     
     doddod::,lxk0Odkkdo:.    
    .;::lodxk0OkkXK0XOc;:.    
         .dkdddkXK0K0do;,     
          XX0KXNKOKOdoc';.    
          WWWNNK0x:',,:,,;    
          ;0Ocolc..'',;,'.    
          cx,''......;'',     
         .0k'..., .  ..''.    
         .dd,......  .....
"
	print_log '%s\n' "$harpya_logo"
	print_log '%s %s\nHost: %s\nVersão do cURL: %s\nData de execução: %s\nEste programa está em domínio público.\nTodas as informações obtidas com o Harpya foram obtidas de forma totalmente legal por meio de dados públicos.\n\n' \
		"$program" "$ver" "$(uname -srmv)" \
		"$(curl -V | awk 'NR==1{print $2}')" "$(date)"

	print_log 'Produtora: %s\nEstado: %s\nPáginas na ANCINE: %s\nURL base da ANCINE: %s\nDiretório de trabalho:%s\nArquivo de caixa-preta (log): %s\n' \
		"$producer_name" "$federative_unit" "$s" "$base_URL" \
		"$working_directory" "$blackbox_file"
	export producer_name federative_unit s base_URL blackbox_file
	new_scrap
}

function print_log {
	test -f "${blackbox_file}" || touch "${blackbox_file}"
	printf "${@}" | /bin/tee -a "${blackbox_file}"
}

function html2text { lynx -width 180 --display_charset=utf-8 -dump "$1"; }

function new_scrap {
	OLDPWD="$PWD"
	mkdir "$working_directory" \
		&& cd "$working_directory"
		do_scrap \
		&& dump_text \
		&& search_in_files
	cd "$OLDPWD"
	return 0
}

function do_scrap {
	# Esse for loop vai baixar todas as páginas do índice 0 até o índice s,
	# informado na linha de comando.
	print_log '%s\n' 'Começando o download das páginas.'
	mkdir -v "${working_directory}/html" \
	       && cd "${working_directory}/html"
	for (( i=0; i<s; i++ )); do
		_scrapped_page=${base_URL##*/}
		scrapped_page=${_scrapped_page%\?*}
		print_log 'Fazendo a transferência da página número %s, localizada em %s.\n' \
			$((i + 1)) "${base_URL}${i}"
		{
			/bin/time curl -sLo "${scrapped_page}.$((i + 1)).html" \
			       	--ciphers 'DEFAULT:!DH' \
			       	-H "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0b; Windows NT 4.0)" \
				"${base_URL}${i}" 2>&1
		} | /bin/tee -a "${blackbox_file}"
	done
	cd "${working_directory}"
}

function dump_text { 
	mkdir -v "${working_directory}/text" | /bin/tee -a "${blackbox_file}"
	cd "${working_directory}"
	html_pages=($(echo "html/*"))
	for (( i=0; i<${#html_pages[@]}; i++ )); do
		html2text "${html_pages[$i]}" > "text/$(basename \
			"${html_pages[$i]}" .html).txt"
	done
}

function search_in_files { 
	cd "${working_directory}"
	test -f "${working_directory}/eureka.txt" || > "${working_directory}/eureka.txt"
	text_pages=($(echo "text/*.txt"))
	for (( i=0; i<${#text_pages[@]}; i++ )); do
		egrep -H -i \
			"${producer_name}.*${federative_unit}|${federative_unit}.*${producer_name}" \
			"${text_pages[$i]}" \
			>>  "${working_directory}/eureka.txt" 2>&1 | /bin/tee -a "${blackbox_file}"
	done	
}

main "${@}" 2>&1
