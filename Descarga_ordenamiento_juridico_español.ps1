# URL de la página inicial
$initialUrl = "https://www.boe.es/biblioteca_juridica/index.php?tipo=C&modo=2"

# Función para obtener los enlaces PDF
function Get-PdfLinks {
    param (
        [string]$url
    )

    # Obtiene el contenido HTML de la página
    $html = Invoke-WebRequest -Uri $url

    # Encuentra todos los enlaces en la página
    $links = $html.Links | Where-Object { $_.href -like "/biblioteca_juridica/*" }

    # Lista para almacenar los enlaces de los PDF
    $pdfLinks = @()

    foreach ($link in $links) {
        # Obtener la URL completa de la página del enlace
        $linkUrl = "https://www.boe.es$($link.href)"

        # Obtener el contenido HTML de la página del enlace
        $linkHtml = Invoke-WebRequest -Uri $linkUrl

        # Encuentra el enlace de descarga del PDF en la página
        $pdfLink = $linkHtml.Links | Where-Object { $_.href -like "*.pdf" }

        if ($pdfLink) {
            # Construir el enlace correcto del PDF
            $correctedPdfLink = "https://www.boe.es/biblioteca_juridica/codigos/$($pdfLink.href)"
            # Añadir el enlace del PDF a la lista
            $pdfLinks += $correctedPdfLink
            
            # Write-Host $correctedPdfLink
            
            # Write-Host $correctedPdfLink.Split("=")[-1]
        }
    }

    return $pdfLinks
}

# Obtener todos los enlaces PDF de la página inicial
$pdfLinks = Get-PdfLinks -url $initialUrl

# Preguntar al usuario si desea descargar los PDF o solo listar los enlaces
$response = Read-Host "¿Deseas descargar los PDF o solo listar los enlaces? (descargar/listar)"

if ($response -eq "descargar") {
    # Directorio de descarga
    $downloadDir = "$env:USERPROFILE\Downloads\PDF"

    # Crear el directorio si no existe
    if (-not (Test-Path $downloadDir)) {
        New-Item -ItemType Directory -Path $downloadDir
    }

    # Descargar cada PDF
    foreach ($pdfLink in $pdfLinks) {
        $fileName = $pdfLink.Split("=")[-1]
        $filePath = Join-Path -Path $downloadDir -ChildPath $fileName

        # Descargar el archivo PDF
        Invoke-WebRequest -Uri $pdfLink -OutFile $filePath
    }

    Write-Output "PDFs descargados en $downloadDir"
} else {
    # Crear un archivo de texto con la lista de enlaces
    $listFilePath = "$env:USERPROFILE\Downloads\PDF\PDF_Links.txt"
    $pdfLinks | Out-File -FilePath $listFilePath

    Write-Output "Lista de enlaces PDF guardada en $listFilePath"
}
