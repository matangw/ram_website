import 'asset_loader_stub.dart'
    if (dart.library.html) 'asset_loader_web.dart' as loader;

Future<String> loadAssetString(String path) => loader.loadAssetString(path);
