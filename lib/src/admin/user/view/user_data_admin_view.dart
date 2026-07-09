import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/admin/user/provider/admin_user_provider.dart';
import 'package:mspeed/src/admin/user/view/create_data_buyer_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_finance_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_penerima_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_seller_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_manager_admin_view.dart';
import 'package:mspeed/src/admin/user/view/create_data_audit_admin_view.dart';
import 'package:mspeed/utils/Utils.dart';
import 'package:provider/provider.dart';

class UserDataAdminView extends StatefulWidget {
  final UserDataType userType;
  const UserDataAdminView({super.key, required this.userType});

  @override
  State<UserDataAdminView> createState() => _UserDataAdminViewState();
}

class _UserDataAdminViewState extends BaseState<UserDataAdminView> {
  // Palet Warna Khas Aplikasi
  final Color appRed = const Color(0xFFED1C24);
  final Color oceanBlue = const Color(0xFF0096C7);
  final Color orangeAcc = const Color(0xFFFF9800);
  final Color yellowAcc = const Color(0xFFFFC300);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminUserProvider>();
      p.searchC.clear();
      _fetchData();
    });
  }

  Future<void> _fetchData({String q = ''}) async {
    setState(() => _isLoading = true);
    final p = context.read<AdminUserProvider>();
    
    try {
      if (widget.userType == UserDataType.BUYER) {
        await p.fetchBuyers(withLoading: false, search: q);
      } else if (widget.userType == UserDataType.SELLER) {
        await p.fetchSellers(withLoading: false, search: q);
      } else if (widget.userType == UserDataType.FINANCE) {
        await p.fetchKeuangan(withLoading: false, search: q);
      } else if (widget.userType == UserDataType.MANAGER) {
        await p.fetchManager(withLoading: false, search: q);
      } else if (widget.userType == UserDataType.AUDIT) {
        await p.fetchAudit(withLoading: false, search: q);
      } else {
        await p.fetchPenerima(withLoading: false, search: q);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();
    final model = provider.userData;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomAppBar.appBar(
        context,
        widget.userType.title,
        color: Colors.white,
        isCenter: true,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        action: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (widget.userType == UserDataType.BUYER) {
                  CusNav.nPush(context, const CreateDataBuyerAdminView());
                } else if (widget.userType == UserDataType.SELLER) {
                  CusNav.nPush(context, const CreateDataSellerAdminView());
                } else if (widget.userType == UserDataType.FINANCE) {
                  CusNav.nPush(context, const CreateDataFinanceAdminView());
                } else if (widget.userType == UserDataType.PENERIMA) {
                  CusNav.nPush(context, const CreateDataPenerimaAdminView());
                } else if (widget.userType == UserDataType.MANAGER) {
                  CusNav.nPush(context, const CreateDataManagerAdminView());
                } else if (widget.userType == UserDataType.AUDIT) {
                  CusNav.nPush(context, const CreateDataAuditAdminView());
                }
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: appRed,
                child: const Icon(Icons.add, size: 22, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(provider.searchC),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: appRed))
                : model.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: appRed,
                        onRefresh: () => _fetchData(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: model.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (c, i) => _buildUserCard(model[i], i, provider),
                        ),
                      ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: controller,
          onSubmitted: (val) => _fetchData(q: val),
          decoration: InputDecoration(
            hintText: "Cari data pengguna...",
            hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: appRed),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 72, color: orangeAcc.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "Belum ada data tersedia",
            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserData user, int index, AdminUserProvider p) {
    final isSeller = widget.userType == UserDataType.SELLER;
    final isAudit = widget.userType == UserDataType.AUDIT;
    final String initial = (user.name1 != null && user.name1!.isNotEmpty) ? user.name1![0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: appRed.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        // Garis merah terang di sisi kiri sebagai identitas khas aplikasi
        border: Border(left: BorderSide(color: appRed, width: 5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BARIS PERTAMA
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: appRed.withOpacity(0.1),
                  child: Text(initial, style: TextStyle(color: appRed, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name1 ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.badge_rounded, size: 14, color: orangeAcc),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.name2 ?? '-',
                              style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // STATUS (KHUSUS SELLER) & POPUP MENU
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildPopupMenu(user, index, p, isAudit),
                    if (isSeller && user.status != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: user.status == 'Aktif' ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          border: Border.all(
                            color: user.status == 'Aktif' ? Colors.green.withOpacity(0.5) : appRed.withOpacity(0.5)
                          )
                        ),
                        child: Text(
                          user.status!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: user.status == 'Aktif' ? Colors.green : appRed,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),

            // INFORMASI EMAIL & ALAMAT DENGAN IKON WARNA-WARNI
            if (!isAudit && user.email != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.email_rounded, size: 16, color: oceanBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.email!,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (user.alamat != null && user.alamat!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: yellowAcc),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.alamat!,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  // LOGIKA POPUP MENU DIKEMBALIKAN 100% SESUAI ASLINYA
  Widget _buildPopupMenu(UserData user, int i, AdminUserProvider p, bool isAudit) {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Colors.black45, size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) async {
          if (value == 'ubah') {
            if (widget.userType == UserDataType.BUYER) {
              CusNav.nPush(context, CreateDataBuyerAdminView(buyer: p.buyerAdminModel.data![i]));
            }
            if (widget.userType == UserDataType.SELLER) {
              CusNav.nPush(context, CreateDataSellerAdminView(seller: p.sellerAdminModel.data![i]));
            }
            if (widget.userType == UserDataType.FINANCE) {
              CusNav.nPush(context, CreateDataFinanceAdminView(keuangan: p.keuanganAdminModel.data![i]));
            }
            if (widget.userType == UserDataType.PENERIMA) {
              CusNav.nPush(context, CreateDataPenerimaAdminView(penerima: p.penerimaAdminModel.data![i]));
            }
            if (widget.userType == UserDataType.MANAGER) {
              CusNav.nPush(context, CreateDataManagerAdminView(manager: p.managerAdminModel.data![i]));
            }
            if (widget.userType == UserDataType.AUDIT) {
              CusNav.nPush(context, CreateDataAuditAdminView(audit: p.auditAdminModel.data![i]));
            }
          } else if (value == 'ganti_sesi') {
            if (widget.userType == UserDataType.BUYER) {
              await p.changeSession(context, p.buyerAdminModel.data?[i]?.ID ?? '');
            }
            if (widget.userType == UserDataType.SELLER) {
              await p.changeSession(context, p.sellerAdminModel.data?[i]?.ID ?? '');
            }
            if (widget.userType == UserDataType.FINANCE) {
              await p.changeSession(context, p.keuanganAdminModel.data?[i]?.ID ?? '');
            }
            if (widget.userType == UserDataType.PENERIMA) {
              await p.changeSession(context, p.penerimaAdminModel.data?[i]?.ID ?? '');
            }
            if (widget.userType == UserDataType.MANAGER) {
              await p.changeSession(context, p.managerAdminModel.data?[i]?.ID ?? '');
            }
  
            } else if (value == 'hapus') {
              await Utils.showYesNoDialog(
                context: context,
                title: 'Konfirmasi Hapus Data',
                desc: 'Apakah Anda yakin ingin hapus data ini?',
                yesCallback: () async {
                  CusNav.nPop(context);
                  // GANTI model[i].id MENJADI user.id
                  if (widget.userType == UserDataType.SELLER) {
                    p.deleteSeller(id: user.id ?? '');
                  }
                  if (widget.userType == UserDataType.BUYER) {
                    p.deleteBuyer(buyerId: user.id ?? '');
                  }
                  if (widget.userType == UserDataType.FINANCE) {
                    p.deleteKeuangan(keuanganId: user.id ?? '');
                  }
                  if (widget.userType == UserDataType.PENERIMA) {
                    p.deletePenerima(penerimaId: user.id ?? '');
                  }
                  if (widget.userType == UserDataType.MANAGER) {
                    p.deleteManager(managerId: user.id ?? '');
                  }
                },
                noCallback: () {
                  CusNav.nPop(context);
                },
              );
            }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem(value: 'ubah', child: _menuItem(Icons.edit, oceanBlue, 'Ubah')),
          ];
          if (!isAudit) {
            items.add(PopupMenuItem(value: 'ganti_sesi', child: _menuItem(Icons.login, orangeAcc, 'Ganti Sesi')));
            items.add(PopupMenuItem(value: 'hapus', child: _menuItem(Icons.delete, appRed, 'Hapus')));
          }
          return items;
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

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