// Shim — migrado para design_system/components/overlays/ds_modal.dart
import 'package:convoquei_app/design_system/components/overlays/ds_modal.dart';
export 'package:convoquei_app/design_system/components/overlays/ds_modal.dart'
    show DSModal, DSBaseModal, DSBaseModalState;

@Deprecated('Use DSBaseModal')
typedef BaseModalStatefulWidget = DSBaseModal;

@Deprecated('Use DSBaseModalState')
typedef BaseModalState<T extends DSBaseModal> = DSBaseModalState<T>;
