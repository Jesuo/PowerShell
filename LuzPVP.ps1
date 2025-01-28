# Fecha de hoy
$hoy = Get-Date -Format "dd-MM-yyyy"

# URL de la API de REE para obtener los precios de la luz

$url = "https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date={0}T00:00&end_date={0}T23:59&time_trunc=hour" -f $hoy

$Json = (((Invoke-WebRequest -Uri $url -Method Get).Content | ConvertFrom-Json).included | Where-Object {$_.type -eq 'PVPC' -and $_.id -eq 1001})

$preciosJson = $Json.attributes.values

# Realizar la solicitud web

try {
        
    # Ordenar los precios de menor a mayor
    $sortedPrices = $preciosJson | Sort-Object -Property value

    # Mostrar los precios por hora
    
    $pricesCustomObject = $preciosJson | ForEach-Object { 
        $fechaYhora = $_.datetime.ToString('dd-MM-yyyy HH:mm') 
        $value = $_.value.ToString("000.00") 
        $color = if ($sortedPrices[0..7] -contains $_) { "`e[32m" } # Green
                elseif ($sortedPrices[-8..-1] -contains $_) { "`e[91m" } # Red
                else { "`e[36m" } #Cyan
	$resetColor = "`e[0m"
        
        [PSCustomObject]@{ 
            Hora = $fechaYhora 
            Precio = $value
            Color = $color
	    ResetColor = $resetColor
            Formato = "│{0} {1} {3}│ {0}{2} €/MWh {3}│" -f $color, $fechaYhora, $value, $resetColor
        }
    }



    ""	
    "                                 `e[42m Ultima actualización: {0}`e[0m" -f $json.attributes.'last-update'
    "`n`e[93m                               Precios mercado peninsular en tiempo real PVPC"
    "`e[97m                                  $hoy Precios de la luz por hora:`n"
    "`e[37m┌─────────────────────────────────┐ ┌─────────────────────────────────┐ ┌─────────────────────────────────┐`e[0m"
    "`e[37m│            Madrugada            │ │                 Día             │ │                Noche            │`e[0m"
    "`e[37m├──────────────────┬──────────────┤ ├──────────────────┬──────────────┤ ├──────────────────┬──────────────┤`e[0m"


    for ($i = 0; $i -lt 8; $i++) {
    '{0} {1} {2}' -f $pricesCustomObject[$i].Formato, $pricesCustomObject[$i + 8].Formato, $pricesCustomObject[$i + 16].Formato   
    }

    "`e[37m└──────────────────┴──────────────┘ └──────────────────┴──────────────┘ └──────────────────┴──────────────┘`e[0m"
    "`n`e[32m$url"
    "`e[32mhttps://www.ree.es/es/datos/apidatos"


} catch {
    "Error al realizar la solicitud: $_"
}


# Aquí https://duffney.io/usingansiescapesequencespowershell encontrareis excelente información sobre como usar secuencias de escape ANSI en Powershell


<#Color	Foreground Code	Background Code
Black	30	40
Red	31	41
Green	32	42
Yellow	33	43
Blue	34	44
Magenta	35	45
Cyan	36	46
White	37	47


Style	Sequence	Reset Sequence
Bold	`e[1m	`e[22m
Underlined	`e[4m	`e[24m
Inverted	`e[7m	`e[27m
Reset all		`e[0m
#>
