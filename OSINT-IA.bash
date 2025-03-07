#!/bin/bash

# Verifica si se ingresó un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <dominio o IP>"
    exit 1
fi

# Variables
objetivo=$1
fecha=$(date +"%Y-%m-%d_%H-%M-%S")
directorio="recon_$objetivo"
informe="$directorio/informe_$fecha.txt"

# Crear directorio de salida
mkdir -p $directorio

echo "⏳ Iniciando recolección de información sobre $objetivo..."
echo "Informe guardado en: $informe"

# Función para agregar resultados al informe
agregar_informe() {
    echo -e "\n\n========== $1 ==========\n" >> $informe
    echo -e "\n$2\n" >> $informe
    echo "✅ $1 completado."
}

# 1. WHOIS
agregar_informe "WHOIS" "$(whois $objetivo)"

# 2. DIG (DNS)
agregar_informe "DIG" "$(dig $objetivo ANY +noall +answer)"

# 3. NSLOOKUP
agregar_informe "NSLOOKUP" "$(nslookup $objetivo)"

# 4. HOST
agregar_informe "HOST" "$(host $objetivo)"

# 5. NMAP (escaneo de puertos)
agregar_informe "NMAP (Top 1000 puertos)" "$(nmap -sV --top-ports 1000 $objetivo)"

# 6. THEHARVESTER (emails y subdominios)
agregar_informe "THEHARVESTER" "$(theHarvester -d $objetivo -l 500 -b all)"

# 7. SUBLIST3R (subdominios)
agregar_informe "SUBLIST3R" "$(sublist3r -d $objetivo)"

# 8. AMASS (Subdominios avanzados)
agregar_informe "AMASS" "$(amass enum -passive -d $objetivo)"

# 9. WHATWEB (tecnologías del sitio)
agregar_informe "WHATWEB" "$(whatweb $objetivo)"

# 10. WAFW00F (Detectar firewall/WAF)
agregar_informe "WAFW00F" "$(wafw00f $objetivo)"

# 11. SSLYZE (Certificados SSL)
agregar_informe "SSLYZE" "$(sslyze --regular $objetivo)"

# 12. CURL (Cabeceras HTTP)
agregar_informe "CURL Headers" "$(curl -I -s $objetivo)"

# 13. NIKTO (Escaneo de vulnerabilidades web)
agregar_informe "NIKTO" "$(nikto -h $objetivo)"

# 14. GOBUSTER (Fuerza bruta de directorios)
agregar_informe "GOBUSTER" "$(gobuster dir -u http://$objetivo -w /usr/share/wordlists/dirb/common.txt)"

# 15. FIERCE (Recon DNS avanzado)
agregar_informe "FIERCE" "$(fierce --domain $objetivo)"

# 16. ENUM4LINUX (Recolección en redes SMB)
agregar_informe "ENUM4LINUX" "$(enum4linux -a $objetivo)"

# 17. SMBCLIENT (Verificación de recursos compartidos SMB)
agregar_informe "SMBCLIENT" "$(smbclient -L //$objetivo -N)"

# 18. HYDRA (Ataques de fuerza bruta SSH)
agregar_informe "HYDRA SSH" "$(hydra -L /usr/share/wordlists/rockyou.txt -P /usr/share/wordlists/rockyou.txt ssh://$objetivo -V)"

# 19. NETCAT (Escaneo manual de puertos)
agregar_informe "NETCAT" "$(nc -zv $objetivo 1-65535)"

# 20. TRACEROUTE (Ruta hacia el objetivo)
agregar_informe "TRACEROUTE" "$(traceroute $objetivo)"

# 21. METAGOOFIL (Recolección de metadatos en documentos)
agregar_informe "METAGOOFIL" "$(metagoofil -d $objetivo -t pdf,doc,xls -l 200 -n 50 -o $directorio/metadata/)"

# 22. XSSer (Detección de vulnerabilidades XSS)
agregar_informe "XSSer" "$(xsser --auto -u http://$objetivo)"

# 23. SQLMAP (Prueba de SQL Injection)
agregar_informe "SQLMAP" "$(sqlmap -u http://$objetivo --batch --random-agent)"

# 24. CMSMAP (Detección de CMS y vulnerabilidades)
agregar_informe "CMSMAP" "$(cmsmap http://$objetivo)"

# 25. WPScan (Vulnerabilidades en WordPress)
agregar_informe "WPScan" "$(wpscan --url http://$objetivo --enumerate u,vp,vt)"

echo "✅ Recolección de información finalizada."
echo "📄 Informe generado en $informe"
