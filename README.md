# TradeGenius Mobile 📱📊

Aplicación móvil de **TradeGenius**, diseñada para ayudar a los usuarios a gestionar sus inversiones, realizar predicciones basadas en Machine Learning y recibir soporte en tiempo real a través de un chatbot financiero.

---

## 📋 Funcionalidades

1. **📊 Dashboard**  
   - Visualización de los principales activos y su desempeño.
   - Gráficos interactivos para tendencias de precios y volumen de acciones.

2. **📈 Predicción**  
   - Realiza predicciones sobre el precio futuro de acciones utilizando modelos **LSTM** y **SVM**.  
   - Presenta gráficos y tendencias para ayudar en la toma de decisiones.

3. **💹 Trading**  
   - Simula órdenes de compra y venta de acciones en tiempo real.  
   - Actualiza automáticamente el balance y los activos después de cada operación.

4. **🤖 Chatbot**  
   - Interacción en tiempo real con un chatbot financiero impulsado por IA.  
   - Respuestas rápidas y precisas sobre el mercado y las operaciones.

---

## 📱 Requisitos Previos

1. **Instalar Flutter**  
   Asegúrate de tener Flutter instalado. Puedes seguir las instrucciones oficiales:  
   [Instalación de Flutter](https://flutter.dev/docs/get-started/install)

2. **Conexión al Backend**  
   El aplicativo está configurado para conectarse al backend desplegado. Asegúrate de que la API esté corriendo en el puerto correcto.

3. **Configuración del Proyecto**  
   - Asegúrate de que el archivo `config.dart` en el proyecto tenga la URL correcta del backend, en caso se esté usando el desplegado en nube:
     ```dart
     const String apiBaseUrl = "https://tradegeniusbackcloud-registry-194080380757.southamerica-west1.run.app";
     ```

---

## 🚀 APK del sistema

Si no desdeas desplegar el proyecto en local, puedes descargar la apk funcional directamente del siguiente link: [TradeGenius_v1.1.0](https://drive.google.com/file/d/1c7Dw5MSs7nTRyVroMfNKxFU7EiNmA6aJ/view?usp=drive_link)

---

### Video de Demostración despliegue local
Para ver una demostración de cómo desplegar el Backend del proyecto en local, y cómo funcionan los endpoints, puedes acceder al siguiente video de presentación:

💻💾 [**Ver Video Instalación y Demo**](https://drive.google.com/file/d/1KhWVoM2A4DdYGpTR3WFjv3oJeZpyTxz7/view?usp=drive_link)

## Equipo E-2024-2:

- Alberto Ramos, Harold Giusseppi
- Azucena Huamantuma, José Antonio
- Chiara Arcos, Bryan Miguel
- Laos Carrasco, Rafael Alonso
- Marcelo Salinas, Moises Enrique
- Mauricio Montes, Jorge Luis
- Montes Perez, Josue Justi
