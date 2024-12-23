
# Fecha de hoy

$hoy = Get-Date -Format "dd-MM-yyyy"

# Fecha de mañana           

$mañana = (Get-Date).AddDays(1).ToString("dd-MM-yyyy")  


# URL de la API de REE para obtener los precios de la luz

Write-Output "`e[93mPrecios mercado peninsular en tiempo real PVPC"

$url = "https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date="+
$hoy+"T00:00&end_date="+$hoy+"T23:59&time_trunc=hour"

Write-Output $url
Write-Output "`e[32mhttps://www.ree.es/es/datos/apidatos"

# Realizar la solicitud web

try {

    $response = Invoke-RestMethod -Uri $url -Method Get

    # Extraer los datos de precios por hora

    $prices = $response.included.attributes.values | Select-Object -First 23

    # Ordenar los precios de menor a mayor

    $sortedPrices = $prices | Sort-Object -Property value 

    # Obtener las 8 horas más baratas y las 8 más caras

    $cheapestHours = $sortedPrices[0..7]

    $mostExpensiveHours = $sortedPrices[-8..-1]

    # Mostrar los precios por hora

    Write-Output "Precios de la luz por hora:"

      foreach ($price in $prices) {

	$hour = $price.datetime

        $value = $price.value

        if ($cheapestHours -contains $price) {

          # Mostrar en color verde

            Write-Output "`e[32m$hour - $value €/MWh`e[0m"

            } 

	elseif ($mostExpensiveHours -contains $price) {

            # Mostrar en color rojo

            Write-Output "`e[91m$hour - $value €/MWh`e[0m"

            } 

	else {

            # Mostrar en color azul claro, cian

            Write-Output "`e[36m$hour - $value €/MWh`e[0m"

            }
  
        }
     } 

    catch {

    Write-Output "Error al realizar la solicitud: $_"

}


#Colores ANSI estándar:
#30: Negro
#31: Rojo
#32: Verde
#33: Amarillo
#34: Azul
#35: Magenta
#36: Cian
#37: Blanco
#Colores ANSI brillantes (con 1; añadido):
#90: Gris oscuro (Brillante)
#91: Rojo claro (Brillante)
#92: Verde claro (Brillante)
#93: Amarillo claro (Brillante)
#94: Azul claro (Brillante)
#95: Magenta claro (Brillante)
#96: Cian claro (Brillante)
#97: Blanco brillante
