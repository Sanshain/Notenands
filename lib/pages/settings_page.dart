import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_hand/main.dart';
import 'package:note_hand/utils/langs.dart';
import 'package:note_hand/widgets/extensions_.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:note_hand/widgets/extensions_.dart';

import '../store/__data.dart';
import '../store/providers_.dart';
import '../utils/validators.dart';
import '../widgets/alerts/yesno.dart';
import '../widgets/dropdown_list.dart';
import '../widgets/switch_field.dart';




final ValueNotifier<Locale?> localeApp = ValueNotifier<Locale?>(null);

Box<dynamic>? settingsDb;


class SettingsPage extends StatefulWidget {
    const SettingsPage({super.key});

    @override
    State<SettingsPage> createState() => EntryState();
}

class EntryState extends State<SettingsPage> {
    int attempts = 0;

    /// for common form validation
    final _form = GlobalKey<FormState>();

    final emailController = TextEditingController();
    final FocusNode emailFocusNode = FocusNode();
    final dropdownState = GlobalKey();

    SettingsNotifier? settingsStore;

    @override
    void initState() {
        super.initState();

        // emailController.text = widget.note?.value ?? '';

        // autofocus = widget.note == null;
    }

    @override
    void didChangeDependencies() {
        // called after initState
        super.didChangeDependencies();

        settingsStore = Provider.of<SettingsNotifier>(context);

        emailController.text = settingsStore?.state.email ?? '';
    }

    @override
    Widget build(BuildContext context) {

        // final settingsStore = Provider.of<SettingsNotifier>(context);
        final settings = settingsStore!.state;

        final categoriesList = Provider.of<CategoriesNotifier>(context);

        final localeName = AppLocalizations.of(context)!.localeName;

        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme
                    .of(context)
                    .secondaryHeaderColor,
                title: Text(AppLocalizations.of(context)!.settingsTitle),
            ),
            body: <Widget>[
                Row(children: <Widget>[
                    TextFormField(
                        // focusNode: emailFocusNode,

                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,

                        validator: validateEmail,

                        style: const TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                            // hintStyle: TextStyle(fontSize: 20.0, color: Colors.redAccent),
                            // hintText: 'Enter valid e-mail',
                            labelText: AppLocalizations.of(context)!.settings__emailPlaceholder, // 'Enter e-mail'
                        ),
                    ).expanded(),
                ]),
                [
                    // const Text('Show category on list page (beta)'),
                    Text(AppLocalizations.of(context)!.settings__uncategorizedList),
                    CupertinoSwitch(
                        // value: settings.showKindsInList,
                        value: settings.showKindsInList ?? true,
                        activeColor: Colors.lightBlueAccent,
                        onChanged: (value) {
                            // setState(() { settings.showKindsInList = value; });
                            settings.showKindsInList = value;
                            settingsStore!.updateAll();
                        },
                    ),
                ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).padding(top: 30),

                [
                    // const Text('Default opening category'),
                    Text(AppLocalizations.of(context)!.settings__defaultCategory),
                    SizedBox(
                        width: 120,
                        // DropdownButtonFormField
                        // DropdownButton
                        child: DropDownList([...categoriesList.values.map((v) => v.name), ''],
                            dropdownState: dropdownState,
                            defaultValue: settings.defaultCategory,
                            // defaultValue: settings.defaultCategory,
                            onChange: (_) {
                                if (_ != null) {
                                    // setState(() { settings.defaultCategory = _ ?? ''; });
                                    settings.defaultCategory = _ ?? '';
                                    settingsStore!.updateAll();
                                }
                            },
                        )
                    ),
                ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).padding(top: 30),

                SwitchField(AppLocalizations.of(context)!.settings__darkTheme, // 'Dark theme',
                    defaultValue: false, onChange: (v){

                    },
                ),

                DropDownField(AppLocalizations.of(context)!.settings__language, languages.values.toList(), // 'language'
                    // defaultValue: settings.language,
                    defaultValue: settings.language.isEmpty ? languages[localeName]! : settings.language,
                    // defaultValue: AppLocalizations.of(context)?.localeName,
                    color: settings.language == 'English' ? Colors.black38 : Colors.black,
                    onChange: (_) {
                        if (_ != null) {
                            // setState(() {
                            //     settings.language = _;
                            //     // settingsDb?.put('settings', settings);
                            //     settings.save();
                            // });

                            settings.language = _;
                            settingsStore!.updateAll();

                            localeApp.value = Locale(
                                settings.language.substring(0, 2).toLowerCase()
                            );

                            // ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(content: Text('Required to reload app to apply language changing'))
                            // );
                        }
                    },
                ),

                MaterialButton(
                    minWidth: double.maxFinite,
                    height: 50,
                    color: Colors.white70,
                    onPressed: () async {
                        final r = await showConfirmDialog(context, text: "Are you sure you want to reset settings to default?");
                        if (r == true){
                            settingsStore?.reset();
                        }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    // clipBehavior: Clip.antiAlias,
                    // child: const Text("Reset"), // Add This
                    child: Text(AppLocalizations.of(context)!.settings__resetButton), // Add This
                ).paddingDirectional(top: 30),

                const Expanded(child: Text('')),

                MaterialButton(
                    minWidth: double.maxFinite,
                    height: 60,
                    color: Theme
                        .of(context)
                        .secondaryHeaderColor,
                    onPressed: () async {
                        if (_form.currentState?.validate() == true) {
                            // settingsDb = settingsDb ?? await Hive.openBox('settings');
                            // settingsDb?.put('email', emailController.value.text);
                            //
                            // settings.email = emailController.value.text;
                            // settings.save();

                            settings.email = emailController.value.text;
                            settingsStore!.updateAll();

                            if (mounted){
                                Navigator.of(context).pop();
                            }
                        }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                    // clipBehavior: Clip.antiAlias,
                    // child: const Text("Save"), // Add This
                    child: Text(AppLocalizations.of(context)!.settings__saveButton), // Add This
                ),
                // CheckboxListTile(
                //     title: Text("title text"),
                //     value: true,
                //     onChanged: (newValue) {
                //         setState(() {
                //             // checkedValue = newValue;
                //         });
                //     },
                //     controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                // )
            ].toColumn().toForm(key: _form).padding(bottom: 15, left: 15, right: 15),
        ).popScope(context, (didPop) {
            if (_form.currentState?.validate() == true) {
                // if (settingsDb != null) {
                //     settingsDb?.put('email', emailController.value.text);
                // } else {
                //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //         content: Text('Db error. Try again please'),
                //     ));
                //     return ++attempts > 1; // one attempt
                // }

                settings.email = emailController.value.text;
                settingsStore!.updateAll();
            }
            return true;
        });
    }

    @override
    void dispose() {
        emailController.dispose();
        super.dispose();
    }
}
