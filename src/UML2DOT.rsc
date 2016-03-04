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
         '  <for (cl <- p.classes) { /* a for loop in a string template, just like PHP */>
         ' \"N<cl.id>\" [label=\"{<cl.id /* a Rascal expression between < > brackets is spliced into the string */>||}\"]
         '  <} /* this is the end of the for loop */>
         '
         '  <for (relation <- p.relations) {>
         '  \"N<relation.a>\" -\> \"N<relation.b>\" [arrowhead=\"empty\"]<}>
         '}";
}

public void callMe(){
	Project p = makeProject(|project://eLib|);
	showDot2(p,|project://Assignment2/out/uml.dot|);
}
