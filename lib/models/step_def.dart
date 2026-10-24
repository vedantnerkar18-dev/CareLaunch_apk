/// One screen of the assessment: a prompt and its answer options.
class StepDef {
  final String prompt;
  final List<String> options;
  final String? helper;

  const StepDef({required this.prompt, required this.options, this.helper});
}