module UML2DOT

import ClassDiagram;
import IO;
import vis::Figure; 
import vis::Render;

bool drawMultiplicities = true;
real edgeLabelSpacing = 2.3;

public void showDot2(Project m, loc out) {
  writeFile(out, dotDiagram2(m));
}

public str dotDiagram2(Project p) {
  return "digraph classes {
         '  fontname = \"Bitstream Vera Sans\"
         '  fontsize = 8
         '  node [ fontname = \"Bitstream Vera Sans\" fontsize = 8 shape = \"record\" ]
         '  edge [ fontname = \"Bitstream Vera Sans\" fontsize = 8 ]
         '
         '  <for (cl <- p.classes) { >
         ' 	\"N<cl.id>\" [label=\"{((<cl.cType>))\\l<cl.cIModifier> <cl.cAModifier> <cl.name>|
         '	<for (att <- cl.attributeSet) {>
         '  <att.aModififier><att.name>: <att.aType> \\l
         '  <}>|
         '	<for (met <- cl.methodset) {>
         '  <met.mModifier><met.name>(): <met.returntype> \\l
         '  <}>}
         '	\"]
         '  <}>
         '
         '  <for (generalization(a,b) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"empty\"]
         '  <}>
         '  <for (realization(a,b) <- p.relations) {>
         '  \"N<a>\" -\> \"N<b>\" [arrowhead=\"empty\" style=\"dashed\"]
         '  <}>
         '  <for (association(a,b, name, mu, hasUpper) <- p.relations) {>
         '  <outputAssociation(a,b,name,mu,hasUpper)>
         '  <}>
         '  <for (aggregration(a,b, name, mu_l, mu_h) <- p.relations) {>
         '  \"N<a>\" -\> \"N<b>\" [arrowhead=\"vee\" arrowtail=\"odiamond\"]
         '  <}>
         '  <for (dependency(a,b) <- p.relations) {>
         '  \"N<a>\" -\> \"N<b>\" [arrowhead=\"normal\"]
         '  <}>
         '  <for (inner(a,b) <- p.relations) {>
         '  \"N<a>\" -\> \"N<b>\" [arrowhead=\"odot\"]
         '  <}>
         '}";
}


private str outputAssociation(loc sourceClass, loc targetClass,str name,int multiplicity,bool hasUpperLimit){

	str result = "";
	
	result += "\"N<sourceClass>\" -\> \"N<targetClass>\" [arrowhead=\"open\", labeldistance=\"<edgeLabelSpacing>\"" ;
	if (drawMultiplicities && multiplicity >= 0) {
		result += ", taillabel=\"<multiplicity>..";
		if (hasUpperLimit)
			result += "<multiplicity>\"";
		else
    		result += "*\"";
    }

	result += "]"; 
	return result;
}

public void createUMLFromProject(loc project, loc output){
	showDot2(makeProject(project),output);
}
