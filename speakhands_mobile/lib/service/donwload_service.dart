import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

// Manages the batch download of all media files for offline use.

/// This service reads all media paths from the `interpreter_function.json`,
/// checks if they already exist locally, and downloads any missing files
/// from the remote server (Ngrok/MinIO).

/// It uses [ChangeNotifier] to report its state ([_isDownloading]),
/// progress ([_progress]), and status ([_statusMessage]) to the UI
/// (like the `SettingsScreen`).
class DownloadService extends ChangeNotifier {
  
  /// The base URL for the remote media server (Ngrok/MinIO).
  final String baseUrl = 'https://orville-unclosable-victoria.ngrok-free.dev';
  // ------------------------------------


  // Internal state: True if a download is currently in progress.
  bool _isDownloading = false;
  String _statusMessage = 'download_information'; 
  
  // Internal state: The download progress from 0.0 to 1.0.
  double _progress = 0.0;

  bool get isDownloading => _isDownloading;
  String get statusMessage => _statusMessage;
  double get progress => _progress;

  /// Initiates the full download process.
  Future<void> startFullDownload(AppLocalizations loc) async {
    if (_isDownloading) return;

    _isDownloading = true;
    _progress = 0.0;
    _statusMessage = loc.download_init; 
    notifyListeners();

    try {
      final List<Map<String, String>> filesToDownload = await _loadAllFilePaths();
      if (filesToDownload.isEmpty) {
        _statusMessage = loc.download_no_files;
        _isDownloading = false;
        notifyListeners();
        return;
      }

      int filesDownloaded = 0;
      int filesSkippedOrFailed = 0;
      final int totalFiles = filesToDownload.length;

      for (final fileInfo in filesToDownload) {
        final String resourceName = fileInfo['path']!;
        final String type = fileInfo['type']!;
        final String cleanName = _cleanPath(resourceName);

        final int percent = (progress * 100).toInt();
        _statusMessage = loc.download_progress(percent.toString());
        notifyListeners();

        final File localFile = await _getLocalFile(cleanName, type);

        if (await localFile.exists()) {
          print("Archivo ya existe, saltando: $cleanName");
          filesSkippedOrFailed++;
        } else {
          try {
            await _downloadAndSaveMedia(cleanName, type);
            filesDownloaded++;
          } catch (e) {
            print("No se pudo descargar $cleanName: $e");
            filesSkippedOrFailed++;
          }
        }
        
        _progress = (filesDownloaded + filesSkippedOrFailed) / totalFiles;
        notifyListeners();
      }

      _statusMessage = loc.download_complete(filesDownloaded.toString());
    } catch (e) { 
      _statusMessage = loc.download_error(e.toString());
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, String>>> _loadAllFilePaths() async {
    final raw =
        await rootBundle.loadString('assets/lexicon/interpreter_function.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final terms = (data['terms'] as List).cast<Map<String, dynamic>>();

    final List<Map<String, String>> paths = [];
    
    for (final term in terms) {
      final media = term['media'] as Map<String, dynamic>?;
      if (media != null) {
        final path = media['path'] as String?;
        final type = media['type'] as String?;
        if (path != null && type != null) {
          paths.add({'path': path, 'type': type});
        }
      }
    }
    return paths;
  }

  Future<void> _downloadAndSaveMedia(String resourceName, String type) async {
    print("Iniciando descarga de: $resourceName");

    String url = '';
    if (type == 'video') {
      url = '$baseUrl/lexicon/videos/$resourceName';
    } else {
      url = '$baseUrl/lexicon/imagenes/$resourceName';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    if (response.statusCode == 200) {
      final File localFile = await _getLocalFile(resourceName, type);
      await localFile.writeAsBytes(response.bodyBytes);
      print("Guardado exitosamente en: ${localFile.path}");
    } else {
      print("Error en descarga (Ngrok $resourceName): ${response.statusCode}");
      throw Exception('Error ${response.statusCode}'); 
    }
  }

  /// Removes the 'assets/' prefix from lexicon paths.
  /// e.g., 'assets/lexicon/videos/hola.mp4' -> 'hola.mp4'
  String _cleanPath(String path) {
    const String prefixVideo = 'assets/lexicon/videos/';
    const String prefixImage = 'assets/lexicon/images/';

    if (path.startsWith(prefixVideo)) {
      return path.substring(prefixVideo.length);
    }
    if (path.startsWith(prefixImage)) {
      return path.substring(prefixImage.length);
    }
    return path;
  }

  /// Returns the local [File] reference for a downloaded (offline) resource.
  /// This creates the 'videos' or 'imagenes' subdirectory if it doesn't exist.
  Future<File> _getLocalFile(String resourceName, String type) async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = (type == 'video') ? 'videos' : 'imagenes';

    final Directory subDir = Directory('${directory.path}/$folder');
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }

    return File('${subDir.path}/$resourceName');
  }
}