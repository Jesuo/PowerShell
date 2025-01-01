# Fecha de hoy
$hoy = Get-Date -Format "dd-MM-yyyy"

# URL de la API de REE para obtener los precios de la luz
Write-Output "`n`e[93m                                Precios mercado peninsular en tiempo real PVPC"

$url = "https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date=$($hoy)T00:00&end_date=$($hoy)T23:59&time_trunc=hour"

# Realizar la solicitud web
try {
    $response = Invoke-RestMethod -Uri $url -Method Get

    # Extraer los datos de precios por hora
    $prices = $response.included.attributes.values | Select-Object -First 24

    # Ordenar los precios de menor a mayor
    $sortedPrices = $prices | Sort-Object -Property value

    # Obtener las 8 horas más baratas y las 8 más caras
    $cheapestHours = $sortedPrices[0..7]
    $mostExpensiveHours = $sortedPrices[-8..-1]

    # Mostrar los precios por hora
    Write-Output "`e[97m                                  $hoy Precios de la luz por hora:`n"
    Write-Output "`e[37m┌─────────────────────────────────┐ ┌─────────────────────────────────┐ ┌─────────────────────────────────┐`e[0m"
    Write-Output "`e[37m|              Madrugada          | |                 Día             | |                Noche            |`e[0m"
    Write-Output "`e[37m├──────────────────┬──────────────┤ ├──────────────────┬──────────────┤ ├──────────────────┬──────────────┤`e[0m"

    $LineaFormateada = @()
    foreach ($price in $prices) {
        $hour = (Get-Date $price.datetime).ToString("dd-MM-yyyy HH:mm")
        $value = $price.value.ToString("000.00")

        if ($cheapestHours -contains $price) {
            # Mostrar en color verde
            $LineaFormateada += "`e[32m| $hour | $value €/MWh |`e[0m"
        } elseif ($mostExpensiveHours -contains $price) {
            # Mostrar en color rojo
            $LineaFormateada += "`e[91m| $hour | $value €/MWh |`e[0m"
        } else {
            # Mostrar en color azul claro, cian
            $LineaFormateada += "`e[36m| $hour | $value €/MWh |`e[0m"
        }
    }

    for ($i = 0; $i -lt 8; $i++) {
        $linea1 = $LineaFormateada[$i]
        $linea2 = $LineaFormateada[$i + 8]
        $linea3 = $LineaFormateada[$i + 16]
        Write-Output "$linea1 $linea2 $linea3"
    }

    Write-Output "`e[37m└──────────────────┴──────────────┘ └──────────────────┴──────────────┘ └──────────────────┴──────────────┘`e[0m"
    Write-Output "`n`e[32m$url"
    Write-Output "`e[32mhttps://www.ree.es/es/datos/apidatos"


} catch {
    Write-Output "Error al realizar la solicitud: $_"
}
