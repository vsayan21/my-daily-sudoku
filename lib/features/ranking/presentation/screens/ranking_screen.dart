import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../profile/application/usecases/load_user_profile.dart';
import '../../../profile/application/usecases/update_avatar_path.dart';
import '../../../profile/application/usecases/update_display_name.dart';
import '../../../profile/data/datasources/user_profile_local_datasource.dart';
import '../../../profile/data/repositories/user_profile_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/widgets/profile_card.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  ProfileController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    final preferences = await widget.dependencies.sharedPreferences;
    final repository = UserProfileRepositoryImpl(
      dataSource: UserProfileLocalDataSource(preferences),
    );
    final controller = ProfileController(
      loadUserProfile: LoadUserProfile(repository: repository),
      updateDisplayName: UpdateDisplayName(repository: repository),
      updateAvatarPath: UpdateAvatarPath(repository: repository),
    );
    await controller.loadProfile();
    if (!mounted) {
      return;
    }
    setState(() => _controller = controller);
  }

  Future<void> _showEditNameSheet(ProfileController controller) async {
    final profile = controller.profile;
    if (profile == null) {
      return;
    }
    final loc = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: profile.displayName);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.profileEditDisplayNameTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                textInputAction: TextInputAction.done,
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: loc.profileDisplayNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await controller.updateDisplayName(textController.text);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(loc.save),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file == null) {
      return;
    }
    await controller.updateAvatarPath(file.path);
  }

  Future<void> _showAvatarPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(loc.profileAvatarGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatarImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(loc.profileAvatarCamera),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatarImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = _controller;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: controller == null
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final profile = controller.profile;
                  if (profile == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loc.navigationProfile,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      ProfileCard(
                        profile: profile,
                        onEditName: () => _showEditNameSheet(controller),
                        onPickAvatar: _showAvatarPicker,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        loc.rankingComingSoon,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
