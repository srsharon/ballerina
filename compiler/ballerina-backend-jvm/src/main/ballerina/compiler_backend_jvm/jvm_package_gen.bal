final map<string> fullQualifiedClassNames = {};

final map<(bir:Call,string)> lambdas = {};

function lookupFullQualifiedClassName(string key) returns string {
    var result = fullQualifiedClassNames[key];

    if (result is string) {
        return result;
    } else {
        error err = error("cannot find full qualified class for method : " + key);
        panic err;
    }
}

public function generateImportedPackage(bir:Package module, map<byte[]> pkgEntries) {

    string orgName = module.org.value;
    string moduleName = module.name.value;

    // TODO: need to get source file name
    string moduleClass = getModuleClassName(untaint orgName, untaint moduleName, untaint moduleName);

    // TODO: remove once the package init class is introduced
    typeOwnerClass = moduleClass;

    // generate object value classes
    ObjectGenerator objGen = new();
    objGen.generateValueClasses(module.typeDefs, pkgEntries);

    generateFrameClasses(module, pkgEntries);

    jvm:ClassWriter cw = new(COMPUTE_FRAMES);
    cw.visit(V1_8, ACC_PUBLIC + ACC_SUPER, moduleClass, null, OBJECT, null);
    generateDefaultConstructor(cw);

    generateUserDefinedTypeFields(cw, module.typeDefs);

    string pkgName = getPackageName(orgName, moduleName);

    // populate function to class name mapping
    foreach var func in module.functions {
        fullQualifiedClassNames[pkgName + func.name.value] = moduleClass;
    }

    // generate methods
    foreach var func in module.functions {
        generateMethod(func, cw, moduleClass);
    }

    cw.visitEnd();

    byte[] classContent = cw.toByteArray();
    pkgEntries[moduleClass + ".class"] = classContent;
}

public function generateEntryPackage(bir:Package module, string sourceFileName, map<byte[]> pkgEntries,
        map<string> manifestEntries) {

    string orgName = module.org.value;
    string moduleName = module.name.value;

    string moduleClass = getModuleClassName(untaint orgName, untaint moduleName, untaint sourceFileName);

    // TODO: remove once the package init class is introduced
    typeOwnerClass = moduleClass;

    // generate object value classes
    ObjectGenerator objGen = new();
    objGen.generateValueClasses(module.typeDefs, pkgEntries);

    generateFrameClasses(module, pkgEntries);

    jvm:ClassWriter cw = new(COMPUTE_FRAMES);
    cw.visit(V1_8, ACC_PUBLIC + ACC_SUPER, moduleClass, null, OBJECT, null);
    generateDefaultConstructor(cw);

    generateUserDefinedTypeFields(cw, module.typeDefs);

    string pkgName = getPackageName(orgName, moduleName);

    // populate function to class name mapping
    foreach var func in module.functions {
        fullQualifiedClassNames[pkgName + func.name.value] = moduleClass;
    }

    bir:Function? mainFunc = getMainFunc(module.functions);
    if (mainFunc is bir:Function) {
        generateMainMethod(mainFunc, cw, module);
        manifestEntries["Main-Class"] = getMainClassName(orgName, moduleName, sourceFileName);
    }

    // generate methods
    foreach var func in module.functions {
        generateMethod(func, cw, moduleClass);
    }

    foreach var (k,v) in lambdas {
        generateLambdaMethod(v[0], cw, v[1], k);
    }

    cw.visitEnd();

    byte[] classContent = cw.toByteArray();
    pkgEntries[moduleClass + ".class"] = classContent;
}

function getModuleClassName(string orgName, string moduleName, string sourceFileName) returns string {
    string name = sourceFileName;

    if (!moduleName.equalsIgnoreCase(".") && !orgName.equalsIgnoreCase("$anon")) {
        name = orgName + "/" + moduleName + "/" + sourceFileName;
    }
    return name;
}

function getMainClassName(string orgName, string moduleName, string sourceFileName) returns string {
    string name = sourceFileName;

    if (!moduleName.equalsIgnoreCase(".") && !orgName.equalsIgnoreCase("$anon")) {
        name = orgName + "." + moduleName + "." + sourceFileName;
    }
    return name;
}

function getPackageName(string orgName, string moduleName) returns string {
    string name = "";

    if (!moduleName.equalsIgnoreCase(".") && !orgName.equalsIgnoreCase("$anon")) {
        name = orgName + "/" + moduleName + "/";
    }

    return name;
}
