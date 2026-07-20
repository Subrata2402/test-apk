import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/core/api_service.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class ReleaseActionButton extends StatefulWidget {
  final AppModel app;
  final ReleaseModel release;
  final bool compact;

  const ReleaseActionButton({super.key, required this.app, required this.release, this.compact = false});

  @override
  State<ReleaseActionButton> createState() => _ReleaseActionButtonState();
}

class _ReleaseActionButtonState extends State<ReleaseActionButton> with WidgetsBindingObserver {
  static const _platform = MethodChannel('com.testapk.app/app_launcher');

  static final List<_ReleaseActionButtonState> _activeStates = [];

  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _errorMessage;
  bool _isDownloaded = false;
  int _installedVersionCode = -1;
  File? _apkFile;
  bool _isInstalling = false;

  bool get _isAppInstalled => _installedVersionCode > -1;
  bool get _isUpdateAvailable => _isAppInstalled && !(_installedVersionCode >= widget.release.buildNumber);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeStates.add(this);
    if (_activeStates.length == 1) {
      _platform.setMethodCallHandler(_handleStaticMethodCall);
    }
    _checkIfDownloaded();
    _checkIfAppInstalled();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activeStates.remove(this);
    if (_activeStates.isEmpty) {
      _platform.setMethodCallHandler(null);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfDownloaded();
      _checkIfAppInstalled();
    }
  }

  static Future<void> _handleStaticMethodCall(MethodCall call) async {
    for (final _ReleaseActionButtonState state in List.from(_activeStates)) {
      if (state.mounted) {
        await state._handleMethodCall(call);
      }
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onInstallStatusChanged') {
      final arguments = call.arguments as Map<dynamic, dynamic>;
      final packageName = arguments['packageName'] as String?;
      final status = arguments['status'] as int?;
      final message = arguments['message'] as String?;
      
      debugPrint('ReleaseActionButton: Received install status change for $packageName: status=$status, message=$message');
      
      if (packageName == widget.app.packageName) {
        if (status == 0) {
          if (mounted) {
            setState(() {
              _isInstalling = false;
            });
            _checkIfDownloaded();
            _checkIfAppInstalled();
          }
        } else if (status != null && status > 0) {
          if (mounted) {
            setState(() {
              _isInstalling = false;
              _errorMessage = message ?? 'Installation failed';
            });
          }
        }
      }
    }
  }

  Future<File> _getApkFile() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final fileName =
        '${widget.app.name.replaceAll(' ', '_')}_v${widget.release.version}_b${widget.release.buildNumber}.apk';
    return File('${dir.path}/$fileName');
  }

  Future<void> _checkIfDownloaded() async {
    final file = await _getApkFile();
    final exists = await file.exists();
    if (mounted) {
      setState(() {
        _apkFile = file;
        _isDownloaded = exists;
      });
    }
  }

  Future<void> _checkIfAppInstalled() async {
    try {
      final Map<dynamic, dynamic>? info = await _platform.invokeMethod('getInstalledVersionInfo', {
        'packageName': widget.app.packageName,
      });
      debugPrint('ReleaseActionButton: getInstalledVersionInfo for "${widget.app.packageName}" returned: $info');
      if (mounted) {
        setState(() {
          _installedVersionCode = info?['versionCode'] as int? ?? -1;
        });
      }
    } catch (e) {
      debugPrint('ReleaseActionButton: Error checking app installation: $e');
      if (mounted) {
        setState(() {
          _installedVersionCode = -1;
        });
      }
    }
  }

  Future<void> _downloadApk() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
    });

    try {
      final file = await _getApkFile();

      final response = await ApiService.instance.downloadRelease(
        widget.app.id,
        widget.release.buildNumber,
        file.path,
        (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (response.statusCode != 200) {
        if (widget.compact && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
              content: Text(
                '$kDownloadFailedMsg${response.statusCode})',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          );
        }
        setState(() {
          _isDownloading = false;
          _errorMessage = widget.compact ? null : '$kDownloadFailedMsg${response.statusCode})';
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
          _apkFile = file;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          content: Text('$kDownloadedMsg${file.path.split('/').last}', style: GoogleFonts.inter(color: Colors.white)),
        ),
      );

      // Automatically trigger installation after successful download
      await _installApk();
    } catch (e) {
      if (mounted) {
        if (widget.compact) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
              content: Text('$kErrorPrefix${e.toString()}', style: GoogleFonts.inter(color: Colors.white)),
            ),
          );
        }
        setState(() {
          _isDownloading = false;
          _errorMessage = widget.compact ? null : '$kErrorPrefix${e.toString()}';
        });
      }
    }
  }

  Future<void> _installApk() async {
    if (_apkFile != null) {
      if (mounted) {
        setState(() {
          _isInstalling = true;
        });
      }
      try {
        final bool success = await _platform.invokeMethod('installApk', {
          'apkPath': _apkFile!.path,
        });
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start installation')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Installation error: $e')),
          );
        }
      }
    }
  }

  Future<void> _launchApp() async {
    try {
      final bool success = await _platform.invokeMethod('launchApp', {'packageName': widget.app.packageName});
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(kLaunchFailedMsg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$kLaunchErrorMsg$e')));
      }
    }
  }

  Color _getButtonColor() {
    if (_isDownloading) {
      return AppColors.accent; // Purple/Indigo
    }
    if (_isInstalling) {
      return AppColors.info; // Blue
    }
    if (_isAppInstalled) {
      if (_isUpdateAvailable) {
        return _isDownloaded ? AppColors.warning : AppColors.accent; // Amber or Purple
      }
      return AppColors.success; // Green (Open)
    }
    return _isDownloaded ? AppColors.warning : AppColors.info; // Amber or Blue
  }

  String _getButtonText() {
    if (_isDownloading) {
      return '$kDownloadingMsg${(_downloadProgress * 100).toStringAsFixed(0)}%';
    }
    if (_isInstalling) {
      return 'Installing...';
    }
    if (_isAppInstalled) {
      if (_isUpdateAvailable) {
        return _isDownloaded ? kInstallUpdateBtnLabel : kUpdateBtnLabel;
      }
      return kOpenAppBtnLabel;
    }
    return _isDownloaded ? kInstallApkBtnLabel : kDownloadApkBtnLabel;
  }

  IconData? _getButtonIcon() {
    if (_isDownloading || _isInstalling) {
      return null;
    }
    if (_isAppInstalled) {
      if (_isUpdateAvailable) {
        return _isDownloaded ? Icons.install_mobile_rounded : Icons.system_update_alt_rounded;
      }
      return Icons.open_in_new_rounded;
    }
    return _isDownloaded ? Icons.install_mobile_rounded : Icons.download_rounded;
  }

  VoidCallback? _getButtonOnTap() {
    if (_isDownloading || _isInstalling) {
      return null;
    }
    if (_isAppInstalled) {
      if (_isUpdateAvailable) {
        return _isDownloaded ? _installApk : _downloadApk;
      }
      return _launchApp;
    }
    return _isDownloaded ? _installApk : _downloadApk;
  }

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = widget.compact ? context.scale(38.0) : context.scale(52.0);
    final double fontSize = widget.compact ? context.scale(13.0) : context.scale(15.0);
    final double iconSize = widget.compact ? context.scale(16.0) : context.scale(20.0);
    final double borderRadius = widget.compact ? context.scale(10.0) : context.scale(14.0);

    final Color primaryColor = _getButtonColor();
    final String buttonText = _getButtonText();
    final IconData? buttonIcon = _getButtonIcon();
    final VoidCallback? onTap = _getButtonOnTap();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(widget.compact ? context.scale(8) : context.scale(12)),
            margin: EdgeInsets.only(bottom: context.scale(8)),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
            ),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: Colors.red.shade300,
                fontSize: widget.compact ? context.scale(11) : context.scale(13),
              ),
            ),
          ),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: widget.compact ? null : double.infinity,
              height: buttonHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: (_isDownloading || _isInstalling)
                      ? [primaryColor.withValues(alpha: 0.40), primaryColor.withValues(alpha: 0.20)]
                      : [primaryColor.withValues(alpha: 0.85), primaryColor.withValues(alpha: 0.60)],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: (_isDownloading || _isInstalling) ? 0.15 : 0.40),
                    blurRadius: context.scale(16),
                    spreadRadius: -2,
                    offset: Offset(0, context.scale(4)),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Padding(
                    padding: widget.compact ? EdgeInsets.symmetric(horizontal: context.scale(16)) : EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: widget.compact ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        if (_isDownloading || _isInstalling)
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: CircularProgressIndicator(
                              value: (_isDownloading && _downloadProgress > 0) ? _downloadProgress : null,
                              strokeWidth: 2,
                              color: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                          )
                        else if (buttonIcon != null)
                          Icon(
                            buttonIcon,
                            size: iconSize,
                            color: Colors.white,
                          ),
                        if (_isDownloading || _isInstalling || buttonIcon != null)
                          SizedBox(width: context.scale(8)),
                        Text(
                          buttonText,
                          style: GoogleFonts.inter(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
