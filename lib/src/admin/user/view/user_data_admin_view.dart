import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/admin/user/view/create_data_buyer_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_finance_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_penerima_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_seller_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_manager_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_audit_admin_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum
// ─────────────────────────────────────────────────────────────────────────────
enum UserDataType {
  BUYER('Data Buyer'),
  SELLER('Data Seller'),
  FINANCE('Data Finance'),
  PENERIMA('Data Penerima'),
  MANAGER('Data Manager'),
  AUDIT('Data Audit');

  final String title;
  const UserDataType(this.title);
}

class UserData {
  final String? name1, name2, email, alamat, id, status;
  UserData({this.name1, this.name2, this.email, this.alamat, this.id, this.status});
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────
class UserDataAdminView extends StatefulWidget {
  const UserDataAdminView({super.key, required this.userType});
  final UserDataType userType;

  @override
  State<UserDataAdminView> createState() => _UserDataAdminViewState();
}

class _UserDataAdminViewState extends BaseState<UserDataAdminView> {
  final TextEditingController _searchC = TextEditingController();
  Timer? _debounce;

  // Theme per UserDataType
  List<Color> get _gradient {
    switch (widget.userType) {
      case UserDataType.BUYER:    return [const Color(0xff3B82F6), const Color(0xff1D4ED8)];
      case UserDataType.SELLER:   return [const Color(0xff10B981), const Color(0xff059669)];
      case UserDataType.FINANCE:  return [const Color(0xffF59E0B), const Color(0xffD97706)];
      case UserDataType.PENERIMA: return [const Color(0xff8B5CF6), const Color(0xff7C3AED)];
      case UserDataType.MANAGER:  return [const Color(0xffEC4899), const Color(0xffBE185D)];
      case UserDataType.AUDIT:    return [const Color(0xff14B8A6), const Color(0xff0F766E)];
    }
  }

  Color get _accentColor => _gradient[0];

  IconData get _headerIcon {
    switch (widget.userType) {
      case UserDataType.BUYER:    return Icons.shopping_bag_rounded;
      case UserDataType.SELLER:   return Icons.storefront_rounded;
      case UserDataType.FINANCE:  return Icons.account_balance_rounded;
      case UserDataType.PENERIMA: return Icons.person_pin_rounded;
      case UserDataType.MANAGER:  return Icons.manage_accounts_rounded;
      case UserDataType.AUDIT:    return Icons.fact_check_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    context.read<AdminUserProvider>().searchC.clear();
    _searchC.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchC.removeListener(_onSearchChanged);
    _searchC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getData(q: _searchC.text);
    });
  }

  Future<void> getData({String q = ''}) async {
    Utils.showLoading();
    final p = context.read<AdminUserProvider>();
    if (widget.userType == UserDataType.BUYER) {
      await p.fetchBuyers(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.SELLER) {
      await p.fetchSellers(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.FINANCE) {
      await p.fetchKeuangan(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.PENERIMA) {
      await p.fetchPenerima(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.MANAGER) {
      await p.fetchManager(withLoading: false, search: q);
    } else if (widget.userType == UserDataType.AUDIT) {
      await p.fetchAudit(withLoading: false, search: q);
    }
    Utils.dismissLoading();
  }

  // ── Navigate to edit form ──
  void _onEdit(int i) {
    final p = context.read<AdminUserProvider>();
    if (widget.userType == UserDataType.BUYER) {
      CusNav.nPush(context, CreateDataBuyerAdminView(buyer: p.buyerAdminModel.data![i]));
    } else if (widget.userType == UserDataType.SELLER) {
      CusNav.nPush(context, CreateDataSellerAdminView(seller: p.sellerAdminModel.data![i]));
    } else if (widget.userType == UserDataType.FINANCE) {
      CusNav.nPush(context, CreateDataFinanceAdminView(keuangan: p.keuanganAdminModel.data![i]));
    } else if (widget.userType == UserDataType.PENERIMA) {
      CusNav.nPush(context, CreateDataPenerimaAdminView(penerima: p.penerimaAdminModel.data![i]));
    } else if (widget.userType == UserDataType.MANAGER) {
      CusNav.nPush(context, CreateDataManagerAdminView(manager: p.managerAdminModel.data![i]));
    } else if (widget.userType == UserDataType.AUDIT) {
      CusNav.nPush(context, CreateDataAuditAdminView(audit: p.auditAdminModel.data![i]));
    }
  }

  // ── Change session ──
  Future<void> _onChangeSession(int i) async {
    final p = context.read<AdminUserProvider>();
    String id = '';
    if (widget.userType == UserDataType.BUYER) id = p.buyerAdminModel.data?[i]?.ID ?? '';
    else if (widget.userType == UserDataType.SELLER) id = p.sellerAdminModel.data?[i]?.ID ?? '';
    else if (widget.userType == UserDataType.FINANCE) id = p.keuanganAdminModel.data?[i]?.ID ?? '';
    else id = p.penerimaAdminModel.data?[i]?.ID ?? '';
    await p.changeSession(context, id);
  }

  // ── Delete ──
  Future<void> _onDelete(int i) async {
    final p = context.read<AdminUserProvider>();
    final model = p.userData;
    await Utils.showYesNoDialog(
      context: context,
      title: 'Konfirmasi Hapus',
      desc: 'Yakin ingin menghapus data "${model[i].name1 ?? ''}"?',
      yesCallback: () async {
        CusNav.nPop(context);
        p.deleteSeller(id: model[i].id ?? '');
      },
      noCallback: () => CusNav.nPop(context),
    );
  }

  // ── Navigate to create ──
  void _onCreate() {
    if (widget.userType == UserDataType.BUYER) {
      CusNav.nPush(context, CreateDataBuyerAdminView());
    } else if (widget.userType == UserDataType.SELLER) {
      CusNav.nPush(context, CreateDataSellerAdminView());
    } else if (widget.userType == UserDataType.FINANCE) {
      CusNav.nPush(context, CreateDataFinanceAdminView());
    } else if (widget.userType == UserDataType.PENERIMA) {
      CusNav.nPush(context, CreateDataPenerimaAdminView());
    } else if (widget.userType == UserDataType.MANAGER) {
      CusNav.nPush(context, CreateDataManagerAdminView());
    } else if (widget.userType == UserDataType.AUDIT) {
      CusNav.nPush(context, CreateDataAuditAdminView());
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdminUserProvider>().userData;
    final isSeller = widget.userType == UserDataType.SELLER;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ──
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: _gradient[1],
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: _onCreate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text('Tambah', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradient,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 68, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_headerIcon, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.userType.title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                              const SizedBox(height: 2),
                              const Text('Kelola dan pantau semua data pengguna',
                                style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search bar ──
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffF5F6FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffE2E4E9)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded, color: Constant.grayColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchC,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, email, atau alamat...',
                          hintStyle: TextStyle(color: Constant.grayColor, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) => getData(q: v),
                      ),
                    ),
                    if (_searchC.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchC.clear();
                          getData();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.close_rounded, color: Constant.grayColor, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Count label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Container(width: 3, height: 14,
                    decoration: BoxDecoration(color: _accentColor, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  Text('Daftar ${widget.userType.title}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff100629))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${model.length} data',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accentColor)),
                  ),
                ],
              ),
            ),
          ),

          // ── List ──
          model.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Belum ada data',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UserCard(
                          userType: widget.userType,
                          item: model[i],
                          index: i,
                          isSeller: isSeller,
                          accentColor: _accentColor,
                          gradient: _gradient,
                          onEdit: () => _onEdit(i),
                          onChangeSession: () => _onChangeSession(i),
                          onDelete: () => _onDelete(i),
                        ),
                      ),
                      childCount: model.length,
                    ),
                  ),
                ),
        ],
      ),
      // Floating refresh
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'refresh_user',
        backgroundColor: _accentColor,
        onPressed: () => getData(q: _searchC.text),
        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserDataType userType;
  final UserData item;
  final int index;
  final bool isSeller;
  final Color accentColor;
  final List<Color> gradient;
  final VoidCallback onEdit;
  final VoidCallback onChangeSession;
  final VoidCallback onDelete;

  const _UserCard({
    required this.userType,
    required this.item,
    required this.index,
    required this.isSeller,
    required this.accentColor,
    required this.gradient,
    required this.onEdit,
    required this.onChangeSession,
    required this.onDelete,
  });

  String get _initials {
    final parts = (item.name1 ?? '?').trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  bool get _isManagerOrAudit =>
      userType == UserDataType.MANAGER || userType == UserDataType.AUDIT;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // ── Card Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: const Color(0xffF0F0F0), width: 1)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(_initials,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                // Name + Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name1 ?? '-',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff100629)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item.email ?? '-',
                        style: const TextStyle(fontSize: 12, color: Color(0xff8A93A3)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Status (seller only)
                if (isSeller && item.status != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.status == 'Aktif'
                          ? const Color(0xff28C76F).withOpacity(0.12)
                          : const Color(0xffED1C24).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(item.status!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.status == 'Aktif'
                            ? const Color(0xff28C76F)
                            : const Color(0xffED1C24),
                      )),
                  ),
                ],
                // ── 3-dots menu ──
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Color(0xff8A93A3), size: 22),
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 8,
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    else if (value == 'session') onChangeSession();
                    else if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    _popupItem(
                      value: 'edit',
                      icon: Icons.edit_rounded,
                      label: 'Ubah Data',
                      iconColor: const Color(0xff3B82F6),
                    ),
                    if (!_isManagerOrAudit) ...[
                      _popupItem(
                        value: 'session',
                        icon: Icons.swap_horiz_rounded,
                        label: 'Ganti Sesi',
                        iconColor: const Color(0xffF59E0B),
                      ),
                      const PopupMenuDivider(height: 1),
                      _popupItem(
                        value: 'delete',
                        icon: Icons.delete_outline_rounded,
                        label: 'Hapus Data',
                        iconColor: const Color(0xffED1C24),
                        textColor: const Color(0xffED1C24),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),

          // ── Card Body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                // Row: name2 & email (label col)
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: isSeller ? 'Nama Pemilik' : 'Last Name',
                        value: item.name2 ?? '-',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoChip(
                        label: 'No. ID',
                        value: '#${item.id ?? '-'}',
                        icon: Icons.tag_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Alamat full width
                _InfoChip(
                  label: 'Alamat',
                  value: item.alamat ?? '-',
                  icon: Icons.location_on_outlined,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupItem({
    required String value,
    required IconData icon,
    required String label,
    required Color iconColor,
    Color? textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor ?? const Color(0xff100629),
            )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Chip Widget
// ─────────────────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffEEEFF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xff8A93A3)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: const TextStyle(fontSize: 10, color: Color(0xff8A93A3), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                  style: const TextStyle(fontSize: 12, color: Color(0xff100629), fontWeight: FontWeight.w600),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
