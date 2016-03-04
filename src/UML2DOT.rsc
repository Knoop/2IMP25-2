module UML2DOT

import ClassDiagram;
import IO;
import vis::Figure; 
import vis::Render;

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
         ' 	\"N<cl.id>\" [label=\"{<cl.id>||}\"]
         '  <}>
         '
         '  <for (generalization(a,b) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"empty\"]
         '  <}>
         '  <for (realization(a,b) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"empty\" style=\"dashed\"]
         '  <}>
         '  <for (association(a,b, name, mu_l, mu_h) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"none\"]
         '  <}>
         '  <for (aggregration(a,b, name, mu_l, mu_h) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"vee\" arrowtail=\"odiamond\"]
         '  <}>
         '  <for (dependency(a,b) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"normal\"]
         '  <}>
         '  <for (inner(a,b) <- p.relations) {>
         '  \"N<b>\" -\> \"N<a>\" [arrowhead=\"odot\"]
         '  <}>
         '}";
}

public void callMe(){
	Class a = class(|java+class://class|, class(), none(), pub(), {});
	Class b = class(|java+class://class2|, class(), abstract(), pub(), {});
	Project p = project({a, b},{generalization(b.id, a.id)});
	showDot2(p,|project://Assignment2/out/uml.dot|);
}
