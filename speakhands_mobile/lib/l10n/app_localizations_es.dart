// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get select_language => 'Selecciona un idioma';

  @override
  String get len_es => 'Español';

  @override
  String get len_en => 'Inglés';

  @override
  String get clear => 'Borrar';

  @override
  String get dictate => 'Dictar';

  @override
  String get speakText => 'Leer texto';

  @override
  String get stopAudio => 'Detener audio';

  @override
  String get interpreter_screen_title => 'Intérprete';

  @override
  String get let_your_sign_be_heard => 'Que tus señas se escuchen';

  @override
  String get learn_info => 'Esta es la sección para aprender lengua de señas.';

  @override
  String get saying => 'Deja que tus manos hablen';

  @override
  String get translator_screen_title => 'Traductor';

  @override
  String get let_your_hands_speak => 'Deja que tus manos hablen';

  @override
  String get translation => 'Traducción:';

  @override
  String get waiting_prediction => 'Esperando predicción...';

  @override
  String get predictions_paused => 'Predicciones en pausa';

  @override
  String get camera_not_active => 'Cámara no activa';

  @override
  String detected_letter(Object letter) {
    return 'Letra detectada: $letter';
  }

  @override
  String get no_hand_detected => 'No se detectó mano';

  @override
  String get camera_toggle_on => 'Cámara activada';

  @override
  String get camera_toggle_off => 'Cámara desactivada';

  @override
  String get reset_message => 'Reiniciando traducción';

  @override
  String get pause_explanation => 'Pausando traducción';

  @override
  String get screen_intro => 'Bienvenido a la pantalla de traductor';

  @override
  String get subtitle_intro => 'Muestra tus manos a la cámara';

  @override
  String get settings_title => 'Ajustes';

  @override
  String get account_section => 'Cuenta';

  @override
  String get personal_data => 'Datos personales';

  @override
  String get account => 'Cuenta';

  @override
  String get privacy_policy => 'Política de privacidad';

  @override
  String get accessibility_section => 'Accesibilidad';

  @override
  String get language => 'Idioma';

  @override
  String get color => 'Apariencia';

  @override
  String get dark_mode => 'Tema actual: Oscuro';

  @override
  String get sure_mode => 'Tema actual: Claro';

  @override
  String get sistem_mode => 'Tema actual: Sistema';

  @override
  String get select_theme => 'seleccionar Tema';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Predeterminado del sistema';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get help_information_section => 'Ayuda e Información';

  @override
  String get terms_and_conditions => 'Términos y condiciones';

  @override
  String get qualife => 'Qualife';

  @override
  String get speech_text => 'Lectura por voz';

  @override
  String get download_tittle => 'Descargar archivos para usar en modo offline';

  @override
  String get download => 'Descargar';

  @override
  String get download_information => 'Descarga videos e imágenes para uso sin conexión';

  @override
  String get download_init => 'Iniciando descarga...';

  @override
  String get download_no_files => 'No se encontraron archivos para descargar.';

  @override
  String download_progress(String percent) {
    return 'Descargando... $percent%';
  }

  @override
  String download_complete(String downloaded) {
    return '¡Descarga completa! ($downloaded archivos)';
  }

  @override
  String download_error(String error) {
    return 'Error fatal: $error';
  }

  @override
  String get hello => 'Hola';

  @override
  String get show => 'Mostrar';

  @override
  String get modal_1 => 'Bienvenido al Traductor de LSM';

  @override
  String get modal_1_text => 'Usa la cámara para traducir tus gestos en tiempo real. Asegúrate de tener buena iluminación.';

  @override
  String get modal_2 => 'Coloca tus manos dentro del recuadro de la cámara.';

  @override
  String get modal_3 => 'Traducción con voz';

  @override
  String get modla_3_text => 'El sistema puede pronunciar las letras o palabras detectadas. Puedes activarlo o pausarlo cuando quieras.';

  @override
  String get modal_1_interpreter => 'Bienvenido al Intérprete de LSM';

  @override
  String get modal_1_interpreter_text => 'Usa el campo de texto para obtener la interpretación en lengua de señas en tiempo real. Escribe con claridad.';

  @override
  String get modal_2_interpreter => 'Escribe el texto que deseas interpretar.';

  @override
  String get modal_3_interpreter => 'Interpretación con voz';

  @override
  String get modal_3_interpreter_text => 'El sistema puede leer en voz alta el texto interpretado. Puedes activarlo o pausarlo cuando quieras.';

  @override
  String get privacy_policy_title => 'Política de Privacidad';

  @override
  String get error_loading_data => 'Error al cargar los datos. Inténtalo nuevamente.';

  @override
  String get effective_date => '25 de Mayo de 2025';

  @override
  String get section_1_title => '1. Información que recopilamos';

  @override
  String get section_1_content => 'Para traducir señas, la aplicación necesita acceso a la cámara de tu dispositivo. SpeakHands no almacena ni transmite imágenes, videos o datos personales capturados por la cámara sin tu consentimiento explícito. Datos no identificables sobre el uso de la aplicación (errores, rendimiento, estadísticas de uso).';

  @override
  String get section_2_title => '2. Uso de la información';

  @override
  String get section_2_content => 'La información se utiliza únicamente para:\n- Reconocer gestos y traducirlos.\n- Mejorar el rendimiento de la app.\n- Corregir errores o fallos.';

  @override
  String get section_3_title => '3. Compartición de información';

  @override
  String get section_3_content => 'SpeakHands no comparte ni vende datos personales a terceros. No se suben imágenes o datos del usuario a servidores externos.';

  @override
  String get section_4_title => '4. Permisos';

  @override
  String get section_4_content => 'La aplicación solicita permisos únicamente para usar la cámara, necesarios para el funcionamiento básico. Puedes revocar estos permisos en cualquier momento desde la configuración de tu dispositivo.';

  @override
  String get section_5_title => '5. Menores de Edad';

  @override
  String get section_5_content => 'La aplicación no está diseñada para ser utilizada por menores de 13 años sin el consentimiento de un adulto responsable.';

  @override
  String get section_6_title => '6. Seguridad';

  @override
  String get section_6_content => 'Utilizamos medidas técnicas y organizativas para proteger tu información contra accesos no autorizados, alteraciones o pérdidas.';

  @override
  String get section_7_title => '7. Derechos del usuario';

  @override
  String get section_7_content => 'Puedes:\n- Solicitar la eliminación de tus datos en cualquier momento.\n- Acceder a esta política desde la aplicación.\n- Contactarnos para dudas o reclamos a [languageappsign@gmail.com](mailto:languageappsign@gmail.com).';

  @override
  String get terms_title => 'Términos y Condiciones';

  @override
  String get terms_section_1_title => '1. Aceptación de los términos';

  @override
  String get terms_section_1_content => 'Al descargar, acceder o utilizar SpeakHands, aceptas estos Términos y Condiciones en su totalidad. Si no estás de acuerdo con ellos, no deberás usar la aplicación.';

  @override
  String get terms_section_2_title => '2. Uso permitido';

  @override
  String get terms_section_2_content => 'La aplicación está destinada únicamente a fines personales, educativos o de apoyo comunicativo. El usuario se compromete a no utilizar la aplicación para actividades ilegales o que infrinjan derechos de terceros. No se debe usar la aplicación para generar contenido ofensivo o discriminatorio.';

  @override
  String get terms_section_3_title => '3. Propiedad intelectual';

  @override
  String get terms_section_3_content => 'Todos los derechos de autor, logotipos, marcas y tecnologías utilizadas en SpeakHands son propiedad del equipo desarrollador y están protegidos por las leyes de propiedad intelectual.';

  @override
  String get terms_section_4_title => '4. Modificaciones al servicio';

  @override
  String get terms_section_4_content => 'Nos reservamos el derecho de modificar o suspender temporal o permanentemente el servicio sin previo aviso. Esto incluye actualizaciones, cambios técnicos o de funcionalidad.';

  @override
  String get terms_section_5_title => '5. Limitación de responsabilidad';

  @override
  String get terms_section_5_content => 'SpeakHands se proporciona \'tal cual\'. No garantizamos una precisión absoluta en la interpretación de señas. SpeakHands no será responsable de daños directos o indirectos derivados del uso o mal uso de la aplicación, incluyendo errores en la traducción o malinterpretaciones.';

  @override
  String get terms_section_6_title => '6. Terminación del uso';

  @override
  String get terms_section_6_content => 'Nos reservamos el derecho de suspender el acceso a la aplicación a cualquier usuario que incumpla estos términos, sin necesidad de previo aviso.';

  @override
  String get help_title => 'Ayuda';

  @override
  String get search_questions => 'Buscar preguntas...';

  @override
  String get faq_title => 'Preguntas frecuentes (FAQ)';

  @override
  String get no_results_found => 'No hemos encontrado resultados para tu búsqueda.';

  @override
  String get see_more => 'Ver más';

  @override
  String get need_more_help => '¿Necesitas más ayuda? ¡Contáctanos!';

  @override
  String get email_app_not_found => 'No se encontró una aplicación de correo configurada.';

  @override
  String get phone_call_failed => 'No se pudo realizar la llamada.';

  @override
  String get faq_q01 => 'No puedo abrir el enlace de correo';

  @override
  String get faq_q01_a1 => 'Instala y configura una app de correo (Gmail/Outlook).';

  @override
  String get faq_q01_a2 => 'Ajustes > Apps predeterminadas > Correo: selecciona tu cliente.';

  @override
  String get faq_q01_a3 => 'Prueba en un dispositivo físico (los emuladores suelen no tener correo).';

  @override
  String get faq_q02 => '¿Cómo puedo restablecer mi contraseña?';

  @override
  String get faq_q02_a1 => 'Ve a Perfil > Cuenta > Restablecer contraseña.';

  @override
  String get faq_q02_a2 => 'Revisa tu correo (spam) para el enlace de restablecimiento.';

  @override
  String get faq_q02_a3 => 'Si no llega, intenta de nuevo o contáctanos por correo.';

  @override
  String get faq_q03 => '¿Cómo cambio mi dirección de correo electrónico?';

  @override
  String get faq_q03_a1 => 'Perfil > Datos personales > Correo electrónico.';

  @override
  String get faq_q03_a2 => 'Verifica el nuevo correo desde el enlace recibido.';

  @override
  String get faq_q03_a3 => 'Cierra sesión y vuelve a entrar si no ves el cambio.';

  @override
  String get faq_q04 => '¿Qué hacer si tengo un problema técnico?';

  @override
  String get faq_q04_a1 => 'Cierra y vuelve a abrir la app.';

  @override
  String get faq_q04_a2 => 'Reinicia el dispositivo.';

  @override
  String get faq_q04_a3 => 'Actualiza a la última versión disponible.';

  @override
  String get faq_q05 => 'La cámara no funciona';

  @override
  String get faq_q05_a1 => 'Asegúrate de haber concedido los permisos de cámara en Ajustes.';

  @override
  String get faq_q05_a2 => 'Cierra otras aplicaciones que puedan estar usando la cámara.';

  @override
  String get faq_q05_a3 => 'Prueba a reiniciar la app o el dispositivo.';

  @override
  String get faq_q05_a4 => 'Revisa que tu cámara esté limpia y sin obstrucciones.';

  @override
  String get faq_q06 => 'La aplicación no responde';

  @override
  String get faq_q06_a1 => 'Cierra y vuelve a abrir la aplicación.';

  @override
  String get faq_q06_a2 => 'Reinicia tu dispositivo.';

  @override
  String get faq_q06_a3 => 'Verifica que tengas la última versión de la aplicación instalada.';

  @override
  String get faq_q06_a4 => 'Si el problema persiste, intenta desinstalar y reinstalar la aplicación.';

  @override
  String get faq_q07 => 'La app no detecta las manos';

  @override
  String get faq_q07_a1 => 'Asegúrate de estar en un lugar bien iluminado.';

  @override
  String get faq_q07_a2 => 'Mantén las manos dentro del cuadro de la cámara.';

  @override
  String get faq_q07_a3 => 'Evita fondos demasiado complejos que puedan interferir con la detección.';

  @override
  String get faq_q07_a4 => 'Asegúrate de que la cámara esté limpia.';

  @override
  String get faq_q08 => 'La traducción es incorrecta';

  @override
  String get faq_q08_a1 => 'Asegúrate de que tu mano esté posicionada correctamente en el cuadro.';

  @override
  String get faq_q08_a2 => 'Revisa que la iluminación sea suficiente para que la cámara pueda detectar las señas.';

  @override
  String get faq_q08_a3 => 'Intenta mover la mano más lentamente para una mejor detección.';

  @override
  String get faq_q08_a4 => 'Si el problema persiste, intenta reiniciar la aplicación.';

  @override
  String get faq_q09 => 'La aplicación se cierra inesperadamente';

  @override
  String get faq_q09_a1 => 'Asegúrate de tener suficiente espacio de almacenamiento en tu dispositivo.';

  @override
  String get faq_q09_a2 => 'Reinicia tu dispositivo para liberar memoria.';

  @override
  String get faq_q09_a3 => 'Si el problema persiste, desinstala y vuelve a instalar la aplicación.';

  @override
  String get faq_q09_a4 => 'Verifica que la aplicación esté actualizada a la última versión.';

  @override
  String get faq_q10 => 'La aplicación no se conecta a Internet';

  @override
  String get faq_q10_a1 => 'Verifica tu conexión a Internet (Wi-Fi o datos móviles).';

  @override
  String get faq_q10_a2 => 'Reinicia tu router o dispositivo si tienes problemas con la conexión.';

  @override
  String get faq_q10_a3 => 'Verifica que la app tenga permisos para acceder a Internet.';

  @override
  String get faq_q10_a4 => 'Prueba desactivando y volviendo a activar la conexión Wi-Fi o datos móviles.';
}
