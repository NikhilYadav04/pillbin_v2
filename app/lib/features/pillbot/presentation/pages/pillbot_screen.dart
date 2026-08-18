import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/pillbot/data/repository/pillbot_provider.dart';
import 'package:pillbin/features/pillbot/presentation/widgets/pillbot_widgets.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/utils/connectivity_banner.dart';

import 'package:provider/provider.dart';

class PillBotScreen extends StatefulWidget {
  final bool isVendor;
  const PillBotScreen({Key? key, this.isVendor = false}) : super(key: key);

  @override
  State<PillBotScreen> createState() => _PillBotScreenState();
}

class _PillBotScreenState extends State<PillBotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  //* listener for location data variables
  bool _locationSuggestionVisible = false;
  bool _locationEnabled = false;
  String? _userLatitude;
  String? _userLongitude;

  File? _pendingFile;
  String? _pendingFileName;
  String _userInitial = 'U';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _scrollCtrl.addListener(_onScroll);
    _inputCtrl.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _inputCtrl.removeListener(_onTextChanged);
    _scrollCtrl.removeListener(_onScroll);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _inputCtrl.text.trim().isNotEmpty;
    if (hasText != _locationSuggestionVisible) {
      setState(() => _locationSuggestionVisible = hasText);
    }
  }

  Future<void> _fetchUserLocation() async {
    // Try UserProvider first
    final user = context.read<UserProvider>().user;
    if (user?.location != null) {
      final loc = user!.location!;
      final name = loc.name ?? '';
      final lat = loc.coordinates?.latitude;
      final lng = loc.coordinates?.longitude;

      if (lat != null && lng != null) {
        _userLatitude = lat.toString();
        _userLongitude = lng.toString();
        return;
      } else if (name.isNotEmpty) {
        return;
      }
    }

    // Fallback to cache
    final cached = await CacheManager().getCachedUserProfile();
    if (cached != null && cached['location'] != null) {
      final loc = cached['location'];
      if (loc is Map) {
        final name = loc['name'] ?? '';
        final coords = loc['coordinates'];
        final lat = coords?['latitude'];
        final lng = coords?['longitude'];

        if (lat != null && lng != null) {
          setState(() {
            _userLatitude = lat.toString();
            _userLongitude = lng.toString();
          });
          return;
        } else if (name.isNotEmpty) {
          return;
        }
      }
    }

    return null;
  }

  Future<void> _loadInitial() async {
    await context
        .read<PillBotProvider>()
        .fetchHistory(reset: true, userId: context.read<UserProvider>().user?.id);
    _scrollToBottom();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final provider = context.read<PillBotProvider>();
    final max = _scrollCtrl.position.maxScrollExtent;
    final cur = _scrollCtrl.position.pixels;

    if (cur >= max - 150 &&
        !provider.isLoadingMessages &&
        provider.hasMorePages) {
      provider.fetchHistory(userId: context.read<UserProvider>().user?.id);
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty && _pendingFile == null) return;

    final file = _pendingFile;
    _inputCtrl.clear();
    setState(() {
      _pendingFile = null;
      _pendingFileName = null;
    });

    _scrollToBottom();

    await context.read<PillBotProvider>().sendMessage(
        userMessage: text.isEmpty ? '📎 File attached' : text,
        file: file,
        userId: context.read<UserProvider>().user?.id,
        latitude: _userLatitude ?? "",
        longitude: _userLongitude ?? "");

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _pickFile() async {
    if (_pendingFile != null) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;
    setState(() {
      _pendingFile = File(picked.path!);
      _pendingFileName = picked.name;
    });
  }

  Future<void> _onClearHistory() async {
    final ok = await _confirm(
      title: 'Clear Chat History',
      body: 'All messages will be permanently deleted.',
      action: 'Clear',
      color: PillBinColors.error,
    );
    if (ok != true || !mounted) return;

    if (mounted) {
      _snack("Clearing Chat History....");
    }
    await context.read<PillBotProvider>().clearHistory(userId: context.read<UserProvider>().user?.id);
  }

  Future<void> _onRefresh() async {
    await context
        .read<PillBotProvider>()
        .fetchHistory(reset: true, userId: context.read<UserProvider>().user?.id);
    _scrollToBottom();
  }

  void _snack(String msg) {
    final sw = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: PillBinRegular.style(
              fontSize: sw * 0.033, color: PillBinColors.textWhite)),
      backgroundColor: PillBinColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<bool?> _confirm(
      {required String title,
      required String body,
      required String action,
      required Color color}) {
    final sw = MediaQuery.of(context).size.width;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: PillBinBold.style(
                fontSize: sw * 0.045, color: PillBinColors.textDark)),
        content: Text(body,
            style: PillBinRegular.style(
                fontSize: sw * 0.035, color: PillBinColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038, color: PillBinColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action,
                style: PillBinBold.style(fontSize: sw * 0.038, color: color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Consumer<PillBotProvider>(
            builder: (context, provider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.errorMessage != null) {
                  _snack(provider.errorMessage!);
                  provider.clearError();
                }
              });

              return Column(
                children: [
                  ConnectivityBanner(),
                  PillBotHeader(
                    isTyping: provider.isQuerying,
                    messageCount: provider.messages.length,
                    onBack: () => Navigator.maybePop(context),
                    onRefresh: _onRefresh,
                    onClearHistory: _onClearHistory,
                    onClearMemory: () async {
                      final ok = await _confirm(
                        title: 'Clear Knowledge Base',
                        body:
                            'PillBot\'s knowledge base based on your PDF\'s will be reset.',
                        action: 'Reset',
                        color: PillBinColors.warning,
                      );

                      if (mounted) {
                        _snack("Clearing PillBot's Knowledge....");
                      }

                      if (ok == true && mounted) {
                        await provider.clearKnowledge(userId: context.read<UserProvider>().user?.id);
                        _snack('Knowledge cleared — PillBot starts fresh!');
                      }
                    },
                  ),
                  Expanded(child: _buildBody(provider)),
                  MessageInputBar(
                    controller: _inputCtrl,
                    isTyping: provider.isQuerying,
                    pendingFiles:
                        _pendingFileName != null ? [_pendingFileName!] : [],
                    onSend: _sendMessage,
                    onPickFile: _pickFile,
                    onRemoveFile: () => setState(() {
                      _pendingFile = null;
                      _pendingFileName = null;
                    }),
                    locationSuggestionVisible: _locationSuggestionVisible,
                    locationEnabled: _locationEnabled,
                    onLocationToggle: (val) async {
                      if (val &&
                          (_userLatitude == null || _userLatitude!.isEmpty)) {
                        await _fetchUserLocation();
                        if (_userLatitude == null || _userLatitude!.isEmpty) {
                          _snack('No location found in your profile.');
                          return;
                        }
                      }
                      setState(() => _locationEnabled = val);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(PillBotProvider provider) {
    if (provider.isLoadingMessages && provider.messages.isEmpty) {
      return const ShimmerMessageLoader();
    }

    if (provider.messages.isEmpty && !provider.isQuerying) {
      return EmptyStateView(
        isVendor: widget.isVendor,
        onSuggestionTap: (label) {
          _inputCtrl.text = label;
          _sendMessage();
        },
      );
    }

    final sw = MediaQuery.of(context).size.width;
    final messages = provider.messages;

    return ListView.builder(
      key: const PageStorageKey('pillbot_list'),
      controller: _scrollCtrl,
      reverse: true,
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.035),
      itemCount: messages.length +
          (provider.isQuerying ? 1 : 0) +
          (provider.isLoadingMessages && messages.isNotEmpty ? 1 : 0),
      itemBuilder: (_, i) {
        if (provider.isQuerying) {
          if (i == 0) return const TypingIndicator();
          i--;
        }

        if (provider.isLoadingMessages &&
            messages.isNotEmpty &&
            i == messages.length) {
          return const PaginationLoader();
        }

        if (i >= messages.length) return const SizedBox.shrink();

        final msg = messages[messages.length - 1 - i];

        return MessageBubble(
          key: ValueKey(msg.id),
          message: msg,
          userInitial: _userInitial,
          animateIn: i == 0,
        );
      },
    );
  }
}
