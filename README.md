### Buenos días profesora, somos Mattia Rizza, Alessandro Scarpino y Martha Troschel, y este es el proyecto final de PAMN.
---

## Introducción
Empezamos por el nombre, **PopVote**. *Pop* es una abreviatura de *PopCorn* que nos remite a la acción más común de comer palomitas mientras vemos una película, y *Vote*, que con una traducción sencilla (Voto) nos lleva a entender que una de las acciones principales será votar una película.   
A partir de aquí nace nuestra aplicación: *una biblioteca de películas* que hemos visto comiendo nuestras queridísimas palomitas y que, al terminar la visualización, **votamos**, **comentamos** y **guardamos** todo esto.  
Nuestra idea nació del deseo de conocer mejor este mundo de la Programación de Aplicaciones Móviles Nativas, cruzándolo con nuestra pasión común por el *cine*.  
No queríamos hacer algo revolucionario, sino tomar ideas de aplicaciones ya existentes y crear la nuestra a nuestro gusto, pensando en un uso futuro en el que estén todas las funciones que nos gustaría encontrar en una aplicación de este tipo, aprovechándolas al máximo.


## Objetivos
El *objetivo* de esta aplicación, como se ha dicho anteriormente, es tener una aplicación que no sea revolucionaria, pero que tenga todas las funciones que querríamos en una aplicación de este tipo.  
Otro objetivo importante es comprender de la mejor manera posible cómo funciona la programación de aplicaciones, un mundo que hasta hace unos meses nos era completamente desconocido.  
**Inicialmente queríamos crearla de una manera muy *básica*.**  
El proyecto consistía en tener una aplicación donde anotar el título, la foto y el comentario de las películas que vemos.  
Debía existir la posibilidad de crear varias secciones, como si fueran álbumes de fotos, de manera que se pudieran dividir las películas vistas por características, periodos de tiempo o actores *( dividirlo como quieras )*  

Cuando subías una película a la aplicación podías:
- Poner el título
- Seleccionar una imagen ( cargarla desde la galería o buscarla en la web )
- Dar una valoración de 1 a 5
- Comentarla   
Además había una sección donde, en base a la valoración que le das, se crea una clasificación de las películas.  
Después quisimos hacer más, creando nuevas páginas y configuraciones para hacerla más completa y darnos más información sobre nuestra biblioteca personal.  
Las actualizaciones las declaramos en el apartado Funcionalidades.

## Diseños
Nuestro [mock-up](https://www.figma.com/design/uQfzdwPi9qhpBUysvN0fXZ/Untitled?node-id=19-76&t=juZ7lFOwtIFstel0-1), donde encontrará la idea inicial, realizada con Figma.


## Arquitectura
Como somos tres personas realizando este proyecto, hemos decidido hacer la misma aplicación, al menos en cuanto a funcionalidades, tanto para *iOS* **(Swift)** como para *Android* **(Kotlin)**.    
En primer lugar hablamos de la arquitectura del proyecto en *Swift*.    
La aplicación ha sido desarrollada utilizando las tecnologías más recientes del ecosistema Apple para garantizar modernidad y mantenibilidad:  
el lenguaje es **Swift 5+**, el framework de interfaz es **SwiftUI**, para la persistencia de datos hemos usado **SwiftData** y el entorno de desarrollo es **Xcode 16+**.  
El corazón de la aplicación se basa en *tres modelos de datos principales*, gestionados mediante el framework SwiftData. Las relaciones han sido diseñadas para garantizar la integridad de los datos.  
El primer modelo es **Film++**, que representa la entidad principal de la aplicación. Los atributos utilizados son **Título**, **Comentario**, **Rating** *(Double)*, **Duración** *(minutos)*, **Género** *(String)* y **Fecha de adición**.  
En cuanto a la gestión de imágenes, el atributo posterData está anotado con **@Attribute(.externalStorage)**. Esta elección arquitectónica permite guardar datos binarios pesados, como *imágenes*, fuera de la base de datos principal, manteniendo las consultas *rápidas y ligeras*.  
El modelo contiene una relación opcional con Folder, ya que una película puede pertenecer a una carpeta o a *ninguna*.  
El segundo modelo es **Folder**, que permite la organización *lógica* de las películas. Los atributos utilizados son únicamente **Nombre e Ícono personalizado**, y su relación es de *“Uno-a-Muchos”* con *Film*.  
Queríamos añadir que hemos aplicado una Decisión de Diseño en cuanto a la “deleteRule”, que hemos configurado como **“.nullify”**. Esto significa que si el usuario elimina una carpeta, las películas que hay dentro no se eliminan, sino que simplemente se desvinculan de la carpeta, preservando los datos del usuario.  
Por último, el tercer modelo es **WishlistItem**, que gestiona una lista separada para las películas que el usuario pretende ver en el futuro. Sus atributos son **Título**, **Poster** y **Fecha de adición**.  

En lo que respecta a la estructura de la Interfaz de Usuario, decidimos que la aplicación adopta una navegación basada en TabView y NavigationStack.  

El **archivo** PopVoteApp configura el *ModelContainer* inyectando los tres modelos mencionados anteriormente en el entorno de la aplicación.
La HomeView gestiona la navegación principal mediante una barra de pestañas (Tab Bar) de cinco elementos, implementando además una pantalla de inicio (Splash Screen) animada con lógica de desvanecimiento temporizado.  
Las secciones de nuestra aplicación son:
1. Library
2. All Films
3. Statistics
4. Wishlist
5. Add
  
- **Library** muestra las carpetas en una cuadrícula realizada con LazyVGrid y implementa un modo de selección personalizado que permite la eliminación múltiple o individual de carpetas. Además utiliza NavigationLink para navegar al detalle de cada carpeta (accediendo específicamente a la vista FolderDetailsView).  

- **All Films** muestra una lista completa de todas las películas vistas, incluyendo la funcionalidad de filtros de ordenación por valoración, orden alfabético y fecha, con la adición de una barra de búsqueda para facilitar la gestión cuando se tienen muchas películas tras un uso prolongado de la aplicación.  
- **Wishlist** funciona de forma muy similar a la página All Films, pero en lugar de contener las películas ya vistas, permite añadir y marcar películas que se quieren ver en el futuro.  
Incluye un workflow “Mover a Biblioteca”, que implementa un botón (marca verde) que transfiere automáticamente un elemento de la Wishlist a la base de datos principal de películas, abriendo una ficha pre-rellenada.  

- **Statistics** es nuestra penúltima sección, donde encontramos un panel analítico que calcula en tiempo real el tiempo total de visualización sumando la duración de todas las películas, así como nuestro género favorito, mediante un algoritmo que calcula la moda estadística de los géneros guardados.  

- Finalmente, **Add** es el formulario completo para la introducción de datos, con validación de campos y selectores personalizados para duración y género.

Queríamos informar también de algunos detalles de implementación relevantes, como el uso de **@Query y las Computed Properties**.  
La aplicación utiliza la macro *@Query de SwiftData* para mantener las vistas siempre sincronizadas con la base de datos. No son necesarios refrescos manuales cuando un dato cambia; la interfaz se actualiza automáticamente.  
Por otro lado, las *Computed Properties* se utilizan de forma intensiva para la lógica de negocio, como el filtrado de búsquedas o el cálculo de estadísticas, garantizando que la lógica resida cerca de la vista que la necesita.  

Por último, hablamos de la **UX** y del **Design System**. Hemos utilizado *componentes reutilizables*, estilos coherentes para las imágenes con el objetivo de crear una identidad visual sólida. Además, para el *feedback visual* hemos utilizado iconos específicos y **alertas de confirmación** para acciones destructivas, mejorando la usabilidad y evitando errores accidentales, como borrar datos por equivocación. La solicitud de confirmación antes de eliminar mejora la experiencia del usuario y previene pérdidas de información.  
En cuanto al guardado de datos, hemos decidido utilizar persistencia local mediante *SwiftData*.
La aplicación usa SwiftData, que gestiona una base de datos **SQLite local** que reside físicamente en la memoria del dispositivo (en la sandbox de la aplicación). Por lo tanto, no es necesaria una conexión a internet porque los datos se guardan en el disco del iPhone.  
Lo hemos implementado por pasos. En primer lugar definimos el modelo de datos **(@Model)**, transformando clases normales de Swift *(Film, Folder y WishlistItem)* en modelos de base de datos simplemente añadiendo la macro *@Model* antes de la definición de la clase.  
Esta macro indica al sistema que cree automáticamente una tabla en la base de datos local con columnas correspondientes a las propiedades de la clase: *título, rating, duración, etcétera*.  
SwiftData gestiona *automáticamente* las relaciones manteniendo la integridad referencial.  
Después, en el archivo principal de la aplicación **(PopVoteApp.swift)**, inicializamos la base de datos usando el modificador
**.modelContainer(for: [Folder.self, Film.self, WishlistItem.self])**, creando el archivo de la base de datos en el disco y preparando la aplicación para leer y escribir en él.  

Además, en las distintas pantallas, por ejemplo en *LibraryView o AllFilmsView*, utilizamos también la macro *@Query* para recuperar los datos.   Se usa porque cuando se añade una película en una pantalla, las demás lo detectan y se actualizan instantáneamente, sin necesidad de código extra para recargar la vista.  
Finalmente, para **guardar** *(insert)* o **eliminar** *(delete)* datos, utilizamos el entorno **@Environment(.modelContext)**, que funciona como un área de staging donde los cambios se realizan en memoria y SwiftData se encarga de guardarlos de forma permanente en el disco, de manera eficiente, mediante autosave.

## Funcionalidades
El objetivo de la aplicación es proporcionar al usuario una **herramienta intuitiva** para catalogar las películas vistas, organizarlas en carpetas personalizadas, llevar un registro de las películas por ver *(Wishlist)* y visualizar estadísticas sobre sus hábitos de visionado.  
Inicialmente, la aplicación había nacido como un espacio muy **sencillo** para guardar las películas vistas, comentarlas y puntuarlas, y si se quería se podían crear carpetas donde poder poner las películas y ordenarlas, y una sección donde, en base a la puntuación, se nos daba un ranking, pero quisimos ampliarla y añadimos nuevas funciones.  
En la página principal encontramos la posibilidad, como se ha dicho antes, de **crear carpetas**, darles el **nombre** que queramos y también, no obligatoriamente, una **imagen**. Si se crea la carpeta equivocada, podemos o bien pulsar el botón **“select”** y luego **eliminarla**, o bien entrar en la carpeta, pulsar el botón **“edit”** para poder *modificar el nombre y/o la imagen*.  
En la sección **“all film”** podemos ver *todas las películas* que hemos añadido, poder *abrirlas* y *ver y/o modificar* la información que les hemos dado; luego hemos añadido la *posibilidad de buscar una película* que hayamos añadido escribiendo su *nombre* y hemos añadido un **filtro** para reordenar las películas del modo que queramos.  
Un gran añadido ha sido la pantalla **“WishList”**, donde podemos añadir las *películas* que nos gustaría ver en el futuro, para mantenerlas allí y no olvidarlas; cuando pulsamos el **“+”** podemos escribir el *título y una imagen*, luego cuando hayamos visto una de las películas puestas en esta página, podremos hacer **clic** sobre la película, pulsar el **tick verde** arriba a la *derecha* y automáticamente, después de insertar la información, la película será **transferida a la página** “all films” y **eliminada** de la *wishlist*.  
Después, el segundo añadido importante ha sido la página **“Stats”**, donde se nos dará la información del **total de horas** de películas visionadas, el **género preferido**, es decir, el género de película más visto y por ultimo una **clasifica de los film preferitos**.  
Por último, pero sin duda el *más importante*, está la página **“add”**, donde tenemos todo lo que necesitamos (después de ver una película) para poder cargarla en nuestra aplicación: se puede **añadir** una *imagen*, **poner el título**, el **género**, la **duración**, una **descripción**, una **puntuación** y finalmente podemos, pero *no obligatoriamente*, **ponerla dentro de una carpeta** ya creada previamente, luego pulsar **“Save Film”** y ocurre la magia. 

Para el modelo de datos usamos SwiftData. Un detalle arquitectónico importante es el uso de **@Attribute(.externalStorage)** para las imágenes de los pósteres. Esto le indica a la base de datos que guarde los datos binarios pesados como archivos externos en el disco, manteniendo liviano el archivo SQLite de la base de datos y haciendo que las consultas sean muy rápidas.
```Swift
@Model
final class Film {
    var title: String
    var rating: Double
    var genre: String
    
    var folder: Folder? 
    
    @Attribute(.externalStorage)
    var posterData: Data?
   }

```

Hemos creado un flujo de usuario fluido para mover una película de la Wishlist a la biblioteca principal. Utilizo un closure onSaveSuccess pasado a la vista de añadido: solo cuando la nueva película está confirmada y guardada en la base de datos, la aplicación procede automáticamente a eliminar el elemento de la Wishlist, garantizando la coherencia de los datos
```Swift
.sheet(isPresented: $isShowingAddSheet) {
    AddFilmView(
        prefilledTitle: item.title,
        prefilledPosterData: item.posterData,
        onSaveSuccess: {            

            modelContext.delete(item)
            
            dismiss()
        }
    )
}
```

