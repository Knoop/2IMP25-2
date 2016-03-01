module Classdiagram

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import List;
import Relation;
import lang::java::m3::Core;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import vis::Figure; 
import vis::Render;

public void showDot2(M3 m, loc out) {
  writeFile(out, dotDiagram2(m));
}

public str dotDiagram2(M3 m) {
  return "digraph classes {
         '  fontname = \"Bitstream Vera Sans\"
         '  fontsize = 8
         '  node [ fontname = \"Bitstream Vera Sans\" fontsize = 8 shape = \"record\" ]
         '  edge [ fontname = \"Bitstream Vera Sans\" fontsize = 8 ]
         '
         '  <for (cl <- classes(m)) { /* a for loop in a string template, just like PHP */>
         ' \"N<cl>\" [label=\"{<cl.path[1..] /* a Rascal expression between < > brackets is spliced into the string */>||}\"]
         '  <} /* this is the end of the for loop */>
         '
         '  <for (<from, to> <- m@extends) {>
         '  \"N<to>\" -\> \"N<from>\" [arrowhead=\"empty\"]<}>
         '}
         '  <for (<from, to> <- m@implements) {>
         '  \"N<to>\" -\> \"N<from>\" [arrowhead=\"empty\"]<}>
         '}";
}

public void stri(){
	m = createM3FromEclipseProject(|project://eLib|);
	showDot2(m, |project://eLib/eLib4.dot|);
}