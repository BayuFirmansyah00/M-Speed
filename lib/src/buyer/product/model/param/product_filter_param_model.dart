class ProductFilterParamModel {
  String categoryId;
  String brandId;
  String tagId;
  String labelId;
  String attributeId;
  String regionId;

  ProductFilterParamModel(
      {this.categoryId = "",
      this.brandId = "",
      this.tagId = "",
      this.labelId = "",
      this.attributeId = "",
      this.regionId = ""});
}
