import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';

class OrganizationHomeCard extends StatelessWidget {
  final OrganizationModel organization;
  final String role;
  final bool isAdmin;

  const OrganizationHomeCard({
    super.key,
    required this.organization,
    required this.role,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrganizationAvatar(photoUrl: organization.photoUrl),
          const SizedBox(height: 10),

          Text(
            organization.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
