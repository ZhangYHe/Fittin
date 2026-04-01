import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class PlanLibraryScreen extends ConsumerWidget {
  const PlanLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(planLibraryItemsProvider);
    final actionState = ref.watch(planLibraryActionProvider);
    final actionNotifier = ref.read(planLibraryActionProvider.notifier);
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final theme = Theme.of(context);

    if (actionState.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionState.infoMessage!)));
        actionNotifier.dismissMessages();
      });
    } else if (actionState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionState.errorMessage!)));
        actionNotifier.dismissMessages();
      });
    }

    return templatesAsync.when(
      data: (templates) => DashboardPageScaffold(
        bottomPadding: 170,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'plan-library-fab',
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PlanEditorScreen()));
            ref.invalidate(planLibraryItemsProvider);
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(strings.newPlan),
        ),
        children: [
          DashboardScreenHeader(
            eyebrow: strings.planLibrary,
            title: strings.planLibrary,
            subtitle: strings.isChinese
                ? '内置计划、自定义模板与切换入口都应该像设计对象，而不是一组暗色表单。'
                : 'Built-in plans, custom templates, and switching flows should feel like premium objects.',
          ),
          const SizedBox(height: 24),
          DashboardSurfaceCard(
            radius: 34,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.isChinese ? '模板收藏' : 'Template Objects',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.isChinese
                      ? '把计划看作可切换、可编辑、可分享的训练对象。激活状态、内置属性和操作层级都应该一眼可见。'
                      : 'Treat every plan as a switchable, editable, shareable training object with visible hierarchy.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.66),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          DashboardSectionLabel(
            label: strings.isChinese ? '全部计划' : 'All Plans',
          ),
          const SizedBox(height: 14),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = templates[index];
              final record = item.record;
              final preview = record.template.workouts
                  .take(3)
                  .map((workout) => localizedWorkoutName(workout, locale))
                  .join(' · ');
              return DashboardSurfaceCard(
                padding: const EdgeInsets.all(22),
                radius: 32,
                highlight: item.isActive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            localizedTemplateName(record.template, locale),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (record.isBuiltIn)
                              _MetaPill(
                                label: strings.builtIn,
                                color: theme.colorScheme.primary,
                              )
                            else
                              _MetaPill(
                                label: strings.custom,
                                color: theme.colorScheme.secondary,
                              ),
                            if (item.isActive) ...[
                              const SizedBox(height: 8),
                              _MetaPill(
                                label: strings.active,
                                color: theme.colorScheme.tertiary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizedTemplateDescription(record.template, locale),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white.withValues(alpha: 0.04),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        preview,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatChip(
                          icon: Icons.calendar_view_week_rounded,
                          label: strings.workoutsCount(
                            record.template.workouts.length,
                          ),
                        ),
                        _StatChip(
                          icon: Icons.fitness_center_rounded,
                          label: strings.exercisesCount(
                            record.template.workouts.fold<int>(
                              0,
                              (sum, workout) => sum + workout.exercises.length,
                            ),
                          ),
                        ),
                        _StatChip(
                          icon: Icons.play_circle_outline_rounded,
                          label: strings.activeInstancesCount(
                            record.instanceCount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: PremiumPrimaryButton(
                            onPressed:
                                item.isActive ||
                                    (actionState.isSwitching &&
                                        actionState.switchingTemplateId ==
                                            record.template.id)
                                ? null
                                : () async {
                                    final trainingMaxProfile =
                                        await _resolveTrainingMaxProfile(
                                          context,
                                          record,
                                        );
                                    if (!context.mounted ||
                                        trainingMaxProfile == null) {
                                      return;
                                    }
                                    await actionNotifier.activateTemplate(
                                      record,
                                      trainingMaxProfile: trainingMaxProfile,
                                    );
                                  },
                            loading:
                                actionState.isSwitching &&
                                actionState.switchingTemplateId ==
                                    record.template.id,
                            icon: item.isActive
                                ? Icons.check_circle_rounded
                                : Icons.play_circle_fill_rounded,
                            label: item.isActive
                                ? strings.current
                                : strings.switchPlan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(62),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              shape: const StadiumBorder(),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.02,
                              ),
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlanEditorScreen(
                                    templateId: record.template.id,
                                  ),
                                ),
                              );
                              ref.invalidate(planLibraryItemsProvider);
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(strings.edit),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}

Future<TrainingMaxProfile?> _resolveTrainingMaxProfile(
  BuildContext context,
  StoredTemplateRecord record,
) async {
  if (record.instanceCount > 0 ||
      record.template.requiredTrainingMaxKeys.isEmpty) {
    return TrainingMaxProfile.empty;
  }

  return showDialog<TrainingMaxProfile>(
    context: context,
    builder: (_) => _TrainingMaxSetupDialog(template: record.template),
  );
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _TrainingMaxSetupDialog extends StatefulWidget {
  const _TrainingMaxSetupDialog({required this.template});

  final PlanTemplate template;

  @override
  State<_TrainingMaxSetupDialog> createState() =>
      _TrainingMaxSetupDialogState();
}

class _TrainingMaxSetupDialogState extends State<_TrainingMaxSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final key in widget.template.requiredTrainingMaxKeys)
        key: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final locale = container.read(appLocaleProvider);
    final strings = AppStrings.fromLocale(locale);
    return AlertDialog(
      title: Text(strings.setTrainingMaxes),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizedTemplateName(widget.template, locale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                strings.isChinese
                    ? '可以先输入已知主项训练最大值，或直接快速开始，之后再去计划编辑页补齐动作起始重量。'
                    : 'Enter known training maxes now, or quick start first and fill in accessory starting loads later in the plan editor.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              for (final liftKey
                  in widget.template.requiredTrainingMaxKeys) ...[
                TextFormField(
                  controller: _controllers[liftKey],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: liftLabelFor(liftKey),
                    hintText: 'kg',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return strings.enterValidMax;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(TrainingMaxProfile.empty),
          child: Text(strings.isChinese ? '快速开始' : 'Quick Start'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              TrainingMaxProfile({
                for (final entry in _controllers.entries)
                  entry.key: double.parse(entry.value.text.trim()),
              }),
            );
          },
          child: Text(strings.startPlan),
        ),
      ],
    );
  }
}
