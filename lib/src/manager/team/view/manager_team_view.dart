import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/src/manager/pesanan/provider/manager_provider.dart';
import 'package:mspeed/src/manager/team/model/manager_team_model.dart';
import 'package:provider/provider.dart';

// ── Brand Colors ───────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1D4ED8);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class ManagerTeamView extends StatefulWidget {
  const ManagerTeamView({super.key});

  @override
  State<ManagerTeamView> createState() => _ManagerTeamViewState();
}

class _ManagerTeamViewState extends BaseState<ManagerTeamView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().fetchTeam(withLoading: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ManagerProvider>();
    final members = p.team.data ?? [];

    // Filtered by search
    final search = p.teamSearchController.text.trim().toLowerCase();
    final filtered = search.isEmpty
        ? members
        : members.where((m) {
            final name = (m.fullName ?? '').toLowerCase();
            final dept = (m.department?.name ?? '').toLowerCase();
            return name.contains(search) || dept.contains(search);
          }).toList();

    return Scaffold(
      backgroundColor: _kBg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: _kSurface,
            surfaceTintColor: _kSurface,
            elevation: 0,
            forceElevated: innerBoxIsScrolled,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(members.length),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchDelegate(
              child: _buildSearchBar(p),
            ),
          ),
        ],
        body: p.isLoadingTeam
            ? const Center(child: CircularProgressIndicator(color: _kPrimary))
            : filtered.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    color: _kPrimary,
                    onRefresh: () async {
                      await p.fetchTeam(withLoading: true);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _buildMemberCard(filtered[i]),
                    ),
                  ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: _kSurface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Anggota Tim',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count Anggota',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Buyer yang berada di bawah naungan Anda',
            style: TextStyle(fontSize: 12, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(ManagerProvider p) {
    return Container(
      color: _kSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search_rounded, size: 20, color: _kTextSecondary),
                  ),
                  Expanded(
                    child: TextField(
                      controller: p.teamSearchController,
                      style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama / departemen...',
                        hintStyle: TextStyle(fontSize: 14, color: _kTextSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (p.teamSearchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: _kTextSecondary),
                      onPressed: () {
                        p.teamSearchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: _kBorder),
        ],
      ),
    );
  }

  // ── Member Card ───────────────────────────────────────────────────────────
  Widget _buildMemberCard(ManagerTeamMember member) {
    final initials = _getInitials(member.fullName ?? member.firstName ?? '?');
    final role = (member.user?.role ?? '').toUpperCase();
    final dept = member.department?.name ?? '-';
    final subdit = member.department?.subDirektorate;
    final phone = member.phone ?? '-';
    final email = member.user?.email ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          member.fullName ?? '-',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (role.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  _MemberInfoRow(icon: Icons.business_rounded, text: dept),
                  if (subdit != null && subdit.isNotEmpty)
                    _MemberInfoRow(icon: Icons.account_tree_rounded, text: subdit),
                  _MemberInfoRow(icon: Icons.phone_rounded, text: phone),
                  _MemberInfoRow(icon: Icons.email_outlined, text: email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 56, color: _kTextSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada anggota tim',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Data anggota tim di bawah Anda\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _kTextSecondary.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────
class _MemberInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MemberInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SliverPersistentHeaderDelegate ────────────────────────────────────────
class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _StickySearchDelegate({required this.child});

  @override
  double get minExtent => 66;
  @override
  double get maxExtent => 66;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black12,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchDelegate old) => old.child != child;
}
