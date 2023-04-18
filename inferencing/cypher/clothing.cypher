// ongdb-enterprise-1.0.x\neosemantics-1.0.x
// Resource Index
CREATE INDEX ON :Resource(uri);

// Index creation
CREATE INDEX ON :Item(itemId);
CREATE INDEX ON :Department(deptName);
CREATE INDEX ON :Category(catName);
CREATE INDEX ON :Brand(brandName);

// Import Clothing Materials Ontology
// 导入服装材料本体
CALL semantics.importOntology("http://www.nsmntx.org/2019/10/clothingMaterials","Turtle", { keepLangTag: true, handleMultival: 'ARRAY'});

// Load data
LOAD CSV WITH HEADERS FROM "file:///next_products.csv"  AS row
MERGE (b:Brand { brandName : row.brandName })
MERGE (dep:Department { deptName: row.itemDepartment })
MERGE (cat:Category { catName: row.itemCategory })
MERGE (i:Item { itemId: row.itemId }) ON CREATE set i.itemName = row.itemName, i.composition = row.itemComposition, i.url = row.url
MERGE (i)-[:IN_CAT]->(cat)
MERGE (i)-[:IN_DEPT]->(dep)
MERGE (i)-[:BY]->(b) ;

// Annotate your data with the ontology
// 将本体和数据实例连接
MATCH (c:Class) UNWIND c.label as langLabel
WITH collect( {key: toLower(semantics.getValue(langLabel)), classNode: c }) as termToClassMap
MATCH (i:Item)
FOREACH (material IN [x in termToClassMap where toLower(i.composition) contains x.key | x.classNode ] | MERGE (i)-[:CONTAINS]->(material)) ;

// Extend the ontology with custom categories
// 自定义扩展本体`AnimalBasedMaterial`
WITH '@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix clmat: <http://www.nsmntx.org/2019/10/clothingMaterials#> .
@prefix ccat: <http://www.nsmntx.org/customCats#> .

ccat:AnimalBasedMaterial
a owl:Class ;
rdfs:label "Animal-based material", "Materiales de origen animal"@es, "matière dorigine animale"@fr .

clmat:Leather
rdfs:subClassOf ccat:AnimalBasedMaterial .

clmat:Silk
rdfs:subClassOf ccat:AnimalBasedMaterial .

clmat:Wool
rdfs:subClassOf ccat:AnimalBasedMaterial .
'
AS onto
CALL semantics.importOntologySnippet(onto,"Turtle", { keepLangTag: true, handleMultival: 'ARRAY'}) YIELD terminationStatus, triplesLoaded
RETURN terminationStatus, triplesLoaded ;

// list synthetic materials  in different languages
// 列出不同语言的`合成材料`
UNWIND ['es','en','fr'] AS lang
MATCH (w:Class { name: 'SyntheticFibre'})<-[:SCO*]-(woolVariant)
RETURN lang, COLLECT(semantics.getLangValue(lang,woolVariant.label)) as syntheticMaterials;

// fleeces by Berghaus
// 使用贝格豪斯的羊毛制作的产品
MATCH (:Category { catName: "Fleeces"})<-[:IN_CAT]-(i:Item)-[:BY]->(:Brand { brandName: "Berghaus"})
RETURN i.itemId as id, i.itemName as name, i.url as url, i.composition as composition;

// Brands producing hoodies
// 哪些品牌生产连帽衫
MATCH (:Category { catName: "Hoodies"})<-[:IN_CAT]-(i:Item)-[:BY]->(b:Brand)
RETURN b.brandName as brand, count(i) as productCount ORDER BY productCount DESC LIMIT 5 ;

// All leather products (explicit and implicit)
// 查找所有皮革制品（显性使用皮革和隐性使用皮革）
MATCH (leather:Class { name: "Leather"})
CALL semantics.inference.nodesInCategory(leather, { inCatRel: "CONTAINS" }) yield node AS product
WITH product MATCH (product)-[:BY]->(b:Brand)
return product.itemName AS product, b.brandName AS brand, product.composition AS composition ;

// Vegan trainers
// 查找没有使用动物材料的产品
MATCH (:Category {catName:"Trainers"})<-[:IN_CAT]-(item:Item)-[:BY]->(b:Brand), (ab:Class { name: "AnimalBasedMaterial"})
WHERE b.brandName IN ["Converse","New Balance","Nike","ASICS"]
AND NOT semantics.inference.inCategory(item,ab,{ inCatRel: "CONTAINS" })
RETURN item.url, item.itemName, item.composition ;







