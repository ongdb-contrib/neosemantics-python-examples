// Resource Index | 导入RDF时需要给`Resource`节点的`uri`创建索引
CREATE INDEX ON :Resource(uri);

// 运行失败！！！
// 导入cnSchema
// https://github.com/cnschema/cnSchema/tree/master/data/releases/4.0/cns-core.jsonId
// https://raw.githubusercontent.com/cnschema/cnSchema/master/data/releases/4.0/cns-core.jsonId
CALL semantics.importOntology(
        'https://raw.githubusercontent.com/cnschema/cnSchema/master/data/releases/4.0/cns-core.jsonId',
        'JSON-LD',
        { keepLangTag: true, handleMultival: 'ARRAY'});

// 运行失败！！！
// 导入cnSchema
// https://github.com/cnschema/cnSchema/tree/master/data/releases/4.0/cns-core.jsonId
CALL semantics.importOntology(
        'file:.//import//cns-core.jsonId',
        'JSON-LD',
        { keepLangTag: true, handleMultival: 'ARRAY'})

// 运行成功！！！
// https://schema.org/version/latest/schemaorg-current-https.jsonld
CALL semantics.importOntology(
        'file:.//import//schema.jsonld',
        'JSON-LD',
        { keepLangTag: true, handleMultival: 'ARRAY'})

// 运行失败！！！
CALL semantics.importOntology(
        'https://schema.org/version/latest/schemaorg-current-https.jsonld',
        'JSON-LD',
        { keepLangTag: true, handleMultival: 'ARRAY'});


