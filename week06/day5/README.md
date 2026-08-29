# Week 6 — Vanguard A/B test

Repo del proyecto (privado): https://github.com/aroaxinping/vanguard-ab-test

Evaluar el test A/B que Vanguard corrió del 15/3 al 20/6 de 2017 sobre su
proceso online, y recomendar si el diseño nuevo sustituye al actual. Entregables:
notebook, dashboard de Tableau y presentación de 10 minutos.

---

## El log registra eventos, no recorridos

Esto es lo que más me costó entender y lo que condiciona todo lo demás. Los
datos web son 755.405 filas de "el cliente X tocó el paso Y en el momento Z".
No dicen dónde acaba un intento y empieza el siguiente.

Y la gente no se mueve en línea recta. **Solo el 28,8% de las visitas es un
recorrido limpio** por el embudo. El 30% tiene más de un `start`, un 7,6% no
tiene ninguno, y hay retrocesos y pasos repetidos por todas partes.

O sea que un recorrido de cliente **hay que reconstruirlo**, y reconstruirlo
exige reglas. Las reglas hay que fijarlas *antes* de calcular nada, porque si
las decides viendo resultados acabas eligiendo la que te da el número que te
gusta.

## La unidad de análisis mueve el resultado 13 puntos

El hallazgo metodológico de la semana. Los mismos datos dan:

- **54,4%** de compleción medida por visita
- **67,4%** medida por cliente

Ninguno está mal, responden preguntas distintas. Pero hay que elegir, y el
criterio no es cuál queda mejor: **el experimento aleatorizó clientes, no
visitas**. Si mides por visita, un cliente que volvió cinco veces pesa cinco
veces más que uno que acertó a la primera, y el equilibrio que te garantiza la
aleatorización desaparece.

Regla general que me llevo: **la unidad de análisis debe coincidir con la
unidad de aleatorización.**

## Significancia ≠ relevancia, con datos de verdad

Ya lo habíamos visto en la semana 5, pero aquí lo vi pasar. Comparando Control
y Test en siete características de cliente, **cuatro salieron significativas**.

Y ninguna importaba: todos los tamaños de efecto por debajo de **0,02**, cuando
el umbral de "efecto pequeño" está en 0,1.

El caso claro es `calls_6_mnth`: p = 0,0005 — parece un hallazgo — y tamaño de
efecto 0,018, que dice que los grupos son intercambiables. Con ~25.000 clientes
por rama, los tests detectan diferencias demasiado pequeñas para significar
nada.

**Nunca reportar un p-valor sin su tamaño de efecto al lado.**

## Definir la métrica antes de ver el resultado

La decisión de la que estoy más contenta. Al reconstruir recorridos hay que
decidir si retroceder cuenta como error. Lo dejamos **abierto a propósito** y
calculamos el Error Rate con dos definiciones: pasos repetidos, y retrocesos.

Con las dos, el diseño nuevo sale **peor** (0,334 → 0,423 y 0,289 → 0,447).
Parecía malo.

Pero no puede ser fricción: si la gente estuviera confundida sería más lenta y
completaría menos, y pasa justo lo contrario — **completa más (+3,4 pp) y
34 segundos antes**. Navegar más mientras terminas antes y con más éxito
significa que moverse por la web es fácil.

Si hubiéramos definido "retroceder = error" de antemano, habríamos penalizado
al diseño por ser cómodo de navegar. Y como fijamos la métrica antes de ver
nada, podemos defender esa interpretación sin que parezca que la elegimos a
posteriori.

## Lo que la media escondía

El resultado medio es +3,4 puntos de compleción. Al abrir por segmentos:

| Edad | Control | Test |
|---|---|---|
| <35 | 64,7% | 69,4% |
| 35–50 | 65,9% | 68,0% |
| 50–65 | 63,9% | 66,7% |
| **65+** | **56,0%** | **60,3%** |

La tentación era decir "el rediseño ayuda más a los mayores". **Contrastamos la
interacción con regresión logística y no es significativa (p = 0,107)** — la
variación entre franjas es compatible con el azar. Así que no lo afirmamos.

Lo que sí es real: los **65+ completan nueve puntos por debajo del resto, en
los dos diseños**. El rediseño los sube como a todos pero no cierra la brecha.
Y son los clientes con más patrimonio y más antigüedad.

Eso pasó de ser "nuestro ángulo" a ser la segunda mitad de la recomendación:
desplegar, y abrir un trabajo aparte con esa brecha.

**Lección**: la hipótesis bonita que no sobrevive al contraste hay que soltarla,
y muchas veces lo que aparece debajo es mejor.

## Gotchas de los datos

- **`step_1`, no `step1`.** El enunciado los escribe sin guion bajo; los datos
  los tienen con él. Los filtros devuelven vacío sin dar error.
- **`Variation` con mayúscula.**
- **20.109 clientes sin aleatorizar** y **49.548 que aparecen en el log sin
  perfil**. Entre los dos, el 57% de los eventos fuera del análisis.
- **331 clientes con más antigüedad que edad.** Imposible. Son el 0,66%, no
  mueven nada, pero avisan de que los campos demográficos traen error.
- **`logons_6_mnth` y `calls_6_mnth` están truncadas**: la primera nunca baja
  de 3 ni pasa de 9, la segunda se corta en 6, y las dos acumulan miles de
  clientes justo en el máximo. Sus medias subestiman la dispersión real.
- Las 2.538 visitas con varios pasos en el mismo segundo eran **exactamente los
  duplicados exactos**. Al limpiarlos desapareció el problema.

## Resultados

**Recomendación: desplegar el rediseño**, y abrir un frente aparte con la
brecha de los mayores.

| KPI | Control | Test | Diferencia |
|---|---|---|---|
| Compleción | 63,54% | 66,94% | **+3,40 pp** (IC 95%: +2,56 a +4,24) |
| Tiempo total | 272 s | 238 s | **−34 s (−12,5%)** |
| Tiempo efectivo | 239 s | 201 s | **−38 s (−15,9%)** |

La mejora en velocidad tiene los **mayores tamaños de efecto de todo el
análisis**, por encima de la de compleción.

Y toda la ganancia de clientes está en el primer paso: +4,91 pp en
`start → step_1`, y prácticamente cero después (−0,99 / +0,26 / +0,38). El
rediseño no hizo el proceso más fácil en general — **quitó un obstáculo en la
puerta de entrada**.

Curiosamente el ahorro de tiempo viene de otro sitio: 7 segundos del primer
paso y **24 del último**. Y `step_1 → step_2` es el único punto que empeora en
las dos métricas.

## Sobre trabajar en equipo con git

Rama propia cada una, PR al cerrar el día, merge a `main`. Lo que de verdad
evita problemas: **un notebook por persona**. Los `.ipynb` son JSON con los
resultados incrustados, y dos personas tocando el mismo archivo generan
conflictos ilegibles. Limpiar los outputs antes de commitear ayuda bastante.

Los datos generados (`data/processed/`) van al `.gitignore` y se regeneran
ejecutando los notebooks. Los crudos sí los versionamos, para que el repo sea
autocontenido y no dependa de que el repo de Ironhack siga existiendo.
