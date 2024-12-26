// To parse this JSON data, do
//
//     final salesReportModel = salesReportModelFromJson(jsonString);

import 'dart:convert';

List<SalesReportModel> salesReportModelFromJson(String str) => List<SalesReportModel>.from(json.decode(str).map((x) => SalesReportModel.fromJson(x)));

String salesReportModelToJson(List<SalesReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SalesReportModel {
  String? totalSales;
  String? netSales;
  String? averageSales;
  int? totalOrders;
  int? totalItems;
  String? totalTax;
  String? totalShipping;
  double? totalRefunds;
  String? totalDiscount;
  String? totalsGroupedBy;
  Map<String, Total>? totals;
  int? totalCustomers;
  Links? links;

  SalesReportModel({
    this.totalSales,
    this.netSales,
    this.averageSales,
    this.totalOrders,
    this.totalItems,
    this.totalTax,
    this.totalShipping,
    this.totalRefunds,
    this.totalDiscount,
    this.totalsGroupedBy,
    this.totals,
    this.totalCustomers,
    this.links,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) => SalesReportModel(
        totalSales: json["total_sales"],
        netSales: json["net_sales"],
        averageSales: json["average_sales"],
        totalOrders: json["total_orders"],
        totalItems: json["total_items"],
        totalTax: json["total_tax"],
        totalShipping: json["total_shipping"],
        totalRefunds: json["total_refunds"],
        totalDiscount: json["total_discount"],
        totalsGroupedBy: json["totals_grouped_by"],
        totals: Map.from(json["totals"]!).map((k, v) => MapEntry<String, Total>(k, Total.fromJson(v))),
        totalCustomers: json["total_customers"],
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "total_sales": totalSales,
        "net_sales": netSales,
        "average_sales": averageSales,
        "total_orders": totalOrders,
        "total_items": totalItems,
        "total_tax": totalTax,
        "total_shipping": totalShipping,
        "total_refunds": totalRefunds,
        "total_discount": totalDiscount,
        "totals_grouped_by": totalsGroupedBy,
        "totals": Map.from(totals!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "total_customers": totalCustomers,
        "_links": links?.toJson(),
      };
}

class Links {
  List<About>? about;

  Links({
    this.about,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        about: json["about"] == null ? [] : List<About>.from(json["about"]!.map((x) => About.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "about": about == null ? [] : List<dynamic>.from(about!.map((x) => x.toJson())),
      };
}

class About {
  String? href;

  About({
    this.href,
  });

  factory About.fromJson(Map<String, dynamic> json) => About(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}

class Total {
  String? sales;
  int? orders;
  int? items;
  String? tax;
  String? shipping;
  String? discount;
  int? customers;

  Total({
    this.sales,
    this.orders,
    this.items,
    this.tax,
    this.shipping,
    this.discount,
    this.customers,
  });

  factory Total.fromJson(Map<String, dynamic> json) => Total(
        sales: json["sales"],
        orders: json["orders"],
        items: json["items"],
        tax: json["tax"],
        shipping: json["shipping"],
        discount: json["discount"],
        customers: json["customers"],
      );

  Map<String, dynamic> toJson() => {
        "sales": sales,
        "orders": orders,
        "items": items,
        "tax": tax,
        "shipping": shipping,
        "discount": discount,
        "customers": customers,
      };
}
