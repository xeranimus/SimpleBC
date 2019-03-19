grammar SimpleBC;
/* This grammar was created to follow the specification provided here:
   https://www.gnu.org/software/bc/manual/html_mono/bc.html */
@header {
import java.util.ArrayList;
import java.math.BigDecimal;
import java.util.HashMap;
}


@members {
abstract class ASTNode {
    ArrayList<ASTNode> children = new ArrayList<ASTNode>();

    public String toString(){
        String str = "(" + this.getClass().getSimpleName();
        for (ASTNode child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }

    abstract Object visit(Env env) throws KeywordExcept;
}

interface Printable {
    public Object visit(Env env, boolean doPrint) throws KeywordExcept;
}

class Root extends ASTNode{
    void add(ASTNode an) {
        //TODO: remove this later
        if (an != null) {
            System.out.println("Adding: " + an);
            children.add(an);
        }
    }

    Object visit(Env env) {

        for (ASTNode child : children) {
            try {
                child.visit(env);
            }
            catch (KeywordExcept ex) {
                System.err.println(ex.getMessage());
                //TODO: should we exit?
            }
        }
        return null;
    }
}

class Expr extends ASTNode implements Printable {
    ExprNode child;
    
    Expr(ExprNode n) {
        child = n;
        children.add(n);
    }

    public BigDecimal visit(Env env) throws KeywordExcept {
        BigDecimal result = child.visit(env);
        //System.out.println("\nVisiting: "  + child.getClass().getSimpleName());
        if ( ! (child instanceof Assign) ) {
            System.out.println(result);
        }
        return result;

    }

    public BigDecimal visit(Env env, boolean doPrint) throws KeywordExcept {
        BigDecimal result = child.visit(env);
        if (doPrint)
            System.out.println(result);
        return result;
    }

}

abstract class ExprNode extends ASTNode {
    abstract BigDecimal visit(Env env);
}

abstract class UnaryExpr extends ExprNode {
    ExprNode child;
    UnaryExpr( ExprNode child) {
        this.child = child;
        this.children.add(child);
    }
}

abstract class BinaryExpr extends ExprNode {
    ExprNode left;
    ExprNode right;
    BinaryExpr(ExprNode left, ExprNode right) {
        this.left = left;
        this.right = right;
        this.children.add(left);
        this.children.add(right);
    }
    
}

class PreInc extends ExprNode {
    String id;
    PreInc(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PreDec extends ExprNode {
    String id;
    PreDec(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PostInc extends ExprNode {
    String id;
    PostInc(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PostDec extends ExprNode {
    String id;
    PostDec(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        //TODO: do the proper memory manipulation
        return BigDecimal.ONE;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class Negate extends UnaryExpr {
    Negate(ExprNode child) {
        super(child);
    }
    BigDecimal visit(Env env)
    {
        return this.child.visit(env).negate();
    }
}

class Power extends BinaryExpr {
    Power(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        return this.left.visit(env).pow(this.right.visit(env).intValue());
    }
}

class Mul extends BinaryExpr {
    Mul(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        return this.left.visit(env).multiply(this.right.visit(env));
    }
}

class Div extends BinaryExpr {
    Div(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        //TODO: change this later
        return this.left.visit(env).divide(this.right.visit(env), 20, BigDecimal.ROUND_DOWN);
    }
}

class Add extends BinaryExpr {
    Add(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        return this.left.visit(env).add(this.right.visit(env));
    }
}

class Sub extends BinaryExpr {
    Sub(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        return this.left.visit(env).subtract(this.right.visit(env));
    }
}

class Assign extends ExprNode {
    String id;
    ExprNode child;
    Assign(String id, ExprNode child) {
        this.id = id;
        this.child = child;
    }

    BigDecimal visit(Env env) {
        BigDecimal value = child.visit(env);
        env.locals().put(id, value);
        return value;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + " " + this.child + ")";
    }
}

class Lt extends BinaryExpr {
    Lt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == -1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Le extends BinaryExpr {
    Le(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == -1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Gt extends BinaryExpr {
    Gt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == 1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Ge extends BinaryExpr {
    Ge(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == 1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Eq extends BinaryExpr {
    Eq(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if ( result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class NotEq extends BinaryExpr {
    NotEq(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if ( result != 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}


class Not extends UnaryExpr {
    Not(ExprNode child) {
        super(child);
    }
        
    BigDecimal visit(Env env) {
        if (this.child.visit(env).equals(BigDecimal.ZERO)) { 
            return BigDecimal.ONE; 
        } 
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class And extends BinaryExpr {
    And(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        if (!(left.visit(env).equals(BigDecimal.ZERO)) && !(right.visit(env).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Or extends BinaryExpr {
    Or(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        if (!(left.visit(env).equals(BigDecimal.ZERO)) || !(right.visit(env).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Var extends ExprNode {
    String id;

    Var(String id) {
        
        this.id = id;
    }

    BigDecimal visit(Env env) {
        if (env.locals().containsKey(id)) {
            return env.locals().get(id);
        }
        else {
            env.locals().put(id, BigDecimal.ZERO);
            return BigDecimal.ZERO;
        }
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }

}


class Const extends ExprNode {
    BigDecimal value;

    Const(BigDecimal value) {
        
        this.value = value;
    }

    BigDecimal visit(Env env) {
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value.toString() + ")";
    }
}


class Func extends ExprNode {
    String name;
    ArrayList<ExprNode> args = new ArrayList<ExprNode>();
    Func(String name, ArrayList<ExprNode> args) {
        this.name = name;
        this.args = args;
        for (ASTNode arg : args) {
            children.add(arg);
        }
    }

    BigDecimal visit(Env env) {
        if (!env.hasFunc(name)) {
            System.err.print("Function " + name + " not defined.");
            System.exit(-1);
            return null;
        }
        else {
            ASTFunc func = env.getFunc(name);
            ArrayList<BigDecimal> inputs = new ArrayList<BigDecimal>();
            for (ExprNode arg : args) {
                inputs.add(arg.visit(env));
            }
            return func.call(env, inputs);
        }
    }
    
}

class Str extends ASTNode implements Printable {
    String value;
    Str(String value) {
        //removing any leading or trailing quotes
        //quotes are forbidden from being in the body of strings, so this is valid
        this.value = value.replace("\"", "");
    }

    String visit(Env env) {
        return this.visit(env, true);
    }

    public String visit(Env env, boolean doPrint) {
        if (doPrint) {
            System.out.print(this.value);
        }
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value + ")";
    }
}

class Print extends ASTNode {
    ArrayList<Printable> children = new ArrayList<Printable>();

    void add(Printable child) {
        children.add(child);
    }

    Object visit(Env env) {
        for (Printable child : children)
        {   
            try {
                Object result = child.visit(env, false);
                if (result instanceof String) {
                    result = ((String) (result)).replace("\\n", "\n");
                }
                System.out.print(result);
            }
            catch (KeywordExcept ex) {
                System.err.println(ex.getMessage());
                System.exit(-1);
            }
        }
        return null;
    }

    public String toString(){
        String str = "(" + this.getClass().getSimpleName();
        for (Printable child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }
}

class Block extends ASTNode {

    void add(ASTNode child) {
        if (child != null) 
            this.children.add(child);
    }

    Object visit(Env env) throws KeywordExcept{
        for (ASTNode child : children)
        {
            child.visit(env);
        }
        return null;
    }
}

class IfElse extends ASTNode { 
    ExprNode cond;
    ASTNode ifNode;
    ASTNode elseNode;

    IfElse(ExprNode cond, ASTNode ifNode) {
        this.cond = cond;
        this.ifNode = ifNode;
        this.elseNode = null;
        children.add(cond);
        children.add(ifNode);
    }

    Object visit(Env env) throws KeywordExcept{
        BigDecimal result = cond.visit(env);
        if (result.equals(BigDecimal.ZERO))
        {
            if (elseNode != null) {
               return this.elseNode.visit(env);
            }
            //TODO return something sensible here?
            return BigDecimal.ZERO;
        }
        else {
            return this.ifNode.visit(env);
        }
    }

    void addElse(ASTNode elseNode) {
        this.elseNode = elseNode;
        this.children.add(elseNode);
    }
}

class While extends ASTNode {
    Expr cond;
    ASTNode body;
    While(ExprNode cond, ASTNode body) {
        this.cond = new Expr(cond);
        this.body = body;
        this.children.add(this.cond);
        this.children.add(body);
    }

    Object visit(Env env) throws KeywordExcept{
        while ( !(cond.visit(env, false).equals(BigDecimal.ZERO)) ) {
            try {
                body.visit(env);
            }
            catch (BreakExcept ex) {
                break;
            }
            catch (ContinueExcept ex) {
                //execution has already been halted for this iteration
                //so we can just move on along
            }
        }
        return null;
    }
}

class For extends ASTNode {
    Expr pre;
    Expr cond;
    Expr post;
    ASTNode body;
    For(ExprNode pre, ExprNode cond, ExprNode post, ASTNode body) {
        this.pre = new Expr(pre);
        this.cond = new Expr(cond);
        this.post = new Expr(post);
        this.body = body;
        this.children.add(this.pre);
        this.children.add(this.cond);
        this.children.add(this.post);
        this.children.add(this.body);
    }

    Object visit(Env env) throws KeywordExcept{
        pre.visit(env, false);
        while ( !(cond.visit(env, false).equals(BigDecimal.ZERO)) ) {
            try {
                body.visit(env);
            }
            catch (BreakExcept ex) {
                break;
            }
            catch (ContinueExcept ex) {
                //execution has already been halted for this iteration
                //so we can just move on along
            }
            post.visit(env);
        }
        return null;
    }
}


abstract class KeywordExcept extends Exception {
    KeywordExcept(String keyword, String place) {
        super("Error: " + keyword + " outside " + place);
    }
}

class BreakExcept extends KeywordExcept {
    BreakExcept() { super("Break", "a for/while"); }
}

class ContinueExcept extends KeywordExcept {
    ContinueExcept() { super("Continue", "a for/while"); }
}

class ReturnExcept extends KeywordExcept {
    BigDecimal retval;
    ReturnExcept(BigDecimal value) {
        super("Return", "of a function.");
        retval = value;
    }
}


class Break extends ASTNode {
    Object visit(Env env) throws KeywordExcept {
        throw new BreakExcept();
    }
}

class Continue extends ASTNode {
    Object visit(Env env) throws KeywordExcept {
        throw new ContinueExcept();
    }
}

class Return extends ASTNode {
    ExprNode child;
    Return(ExprNode child) {
        this.child = child;
        children.add(child);
    }

    Object visit(Env env) throws KeywordExcept {
        throw new ReturnExcept(child.visit(env));
    }
}


class Halt extends ASTNode {
    Object visit(Env env) {
        // TODO: possibly exit more gracefully?
        System.exit(0);
        return null;
    }
}

class ASTFunc {
    String name;
    ArrayList<String> args;
    ASTNode body;
    ASTFunc(String name, ArrayList<String> args, ASTNode body) {
        this.name = name;
        this.args = args;
        this.body = body;
    }

    BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        if (input_args.size() != args.size() ) {
            System.err.println("Function received " + input_args.size() + " args, expected " + input_args.size());
            System.exit(-1);
        }
        // push new map onto the Environment stack
        env.push();
        for (int i = 0; i < args.size(); i++ ) {
            String name = args.get(i);
            BigDecimal value = input_args.get(i);
            env.locals().put(name, value);
        }
        BigDecimal retval = BigDecimal.ZERO;
        try {
            this.body.visit(env);
        }
        catch (ReturnExcept ex) {
            retval = ex.retval;
        }
        catch (KeywordExcept ex) {
            System.err.println(ex.getMessage());
            System.exit(-1);
        }
        //if no exception occurs, then no return value specified
        // remove the locals from the Environment stack
        env.pop();
        return retval;
    }
}

class Env {
    ArrayList<HashMap<String, BigDecimal>> stack = new ArrayList<HashMap<String, BigDecimal>>();
    
    HashMap<String, ASTFunc> functions = new HashMap<String, ASTFunc>();
    Env() {
        this.push();
    }

    HashMap<String, BigDecimal> locals() {
        return stack.get(stack.size()-1);
    }

    HashMap<String, BigDecimal> globals() {
        return stack.get(0);
    }

    void pop() {
        stack.remove(stack.size()-1);
    }

    void push() {
        stack.add(new HashMap<String, BigDecimal>());
    }

    boolean hasVar(String id) {
        if (locals().containsKey(id)) {
            return true;
        }
        return globals().containsKey(id);
    }

    BigDecimal getVar(String id) {
        if (locals().containsKey(id)) {
            return locals().get(id);
        }
        if (globals().containsKey(id)) {
            return globals().get(id);
        }
        locals().put(id, BigDecimal.ZERO);
        return BigDecimal.ZERO;
    }

    void putVar(String id, BigDecimal value)
    {
        //check if it's a local variable first
        if (locals().containsKey(id)) {
           locals().put(id, value);
        }
        //other
        else {
            globals().put(id, value);
        }
    }

    boolean hasFunc(String name) {
        return functions.containsKey(name);
    }

    void putFunc(ASTFunc func) {
        functions.put(func.name, func);
    }

    ASTFunc getFunc(String name) {
        return functions.get(name);
    }
}

}

file: 
    { Root root = new Root(); Env env = new Env(); }
    (st=statement { root.add($st.an); }| def=define { env.putFunc($def.f); }) ( ( SEMI | ENDLINE | SEMI ENDLINE ) ( nxt=statement { root.add($nxt.an);} | define { env.putFunc($def.f); } | EOF ))* EOF?
    {  System.err.println(root); root.visit(env); }
    ;

define returns [ASTFunc f]:
    {ArrayList<String> args = new ArrayList<String>(); }
    'define' name=ID '(' (fa=ID {args.add($fa.text);} (',' na=ID {args.add($na.text);})*)? ')' ENDLINE? 
    { Block body = new Block(); } 
    '{' ENDLINE? (fs=statement {body.add($fs.an);} ( ( SEMI | ENDLINE | SEMI ENDLINE ) fn=statement {body.add($fn.an);})*)? ENDLINE? '}' 
    { $f = new ASTFunc($name.text, args, body); }  ; 

statement returns [ASTNode an]:
      e=expr   { $an= new Expr($e.en);} 
    | s=STRING { $an= new Str($s.text);}
    | 'print' { Print p = new Print(); $an = p; } fp=printable { p.add($fp.pn); } ( COMMA                   np=printable {p.add($np.pn);})*
    | '{'     { Block b = new Block(); $an = b; } ( fs=statement { b.add($fs.an); }  ((SEMI | ENDLINE | SEMI ENDLINE ) ns=statement {b.add($ns.an);})*)? '}' 
    | 'if' '(' con=expr ')'  ifs=statement {IfElse ie = new IfElse($con.en, $ifs.an); $an = ie;} ('else' elses=statement { ie.addElse($elses.an);} )? {}
    | 'while' '(' cond=expr ')' ENDLINE? stat=statement { $an = new While($cond.en, $stat.an); }
    | 'for' '(' pre=expr SEMI cond=expr SEMI post=expr ')' ENDLINE? stat=statement{ $an = new For($pre.en, $cond.en, $post.en, $stat.an); }
    | 'break'    { $an = new Break(); }
    | 'continue' { $an = new Continue(); }
    | 'halt'     { $an = new Halt(); } /* end bc upon execution */
    | 'exit'     { System.exit(0); }   /* exit bc immediately */
    | 'return'   { ExprNode value = new Const(BigDecimal.ZERO); } ( value=expr {value = $value.en;})? { $an = new Return(value) ;} /* if no value is provided, return 0 */
    ;

printable returns [Printable pn]:
    | e=expr { $pn = new Expr($e.en); }
    | s=STRING { $pn = new Str($s.text); }
    ;

testExpr:
     e=expr {  Env env = new Env(); System.out.println($e.en); System.out.println($e.en.visit(env));}
    ;

expr returns [ExprNode en]:
      op='++' ID { $en = new PreInc($ID.text); }
    | op='--' ID { $en = new PreDec($ID.text); }
    | ID op='++' { $en = new PostInc($ID.text); }
    | ID op='--' { $en = new PostDec($ID.text); }
    | op='-' e=expr { $en = new Negate($e.en); }
    | <assoc=right> el=expr op='^' er=expr { $en = new Power($el.en, $er.en); }
    | el=expr op=('*'|'/') er=expr { $en=($op.text.equals("*")) ? new Mul($el.en, $er.en) : new Div($el.en, $er.en); }
    | el=expr op=('+'|'-') er=expr { $en=($op.text.equals("+")) ? new Add($el.en, $er.en) : new Sub($el.en, $er.en); }
    | '(' e=expr ')' { $en = $e.en; } 
    /* assignment */
    | ID '=' e=expr { $en = new Assign($ID.text, $e.en); }
    /* relational expressions */
    | el=expr '<'  er=expr { $en = new Lt($el.en, $er.en); }
    | el=expr '<=' er=expr { $en = new Le($el.en, $er.en); }
    | el=expr '>'  er=expr { $en = new Gt($el.en, $er.en); }
    | el=expr '>=' er=expr { $en = new Ge($el.en, $er.en); }
    | el=expr '==' er=expr { $en = new Eq($el.en, $er.en); }
    | el=expr '!=' er=expr { $en = new NotEq($el.en, $er.en); }
    /* boolean expressions */
    | op='!' e=expr { $en = new Not($e.en); }
    | el=expr op='&&' er=expr { $en = new And($el.en, $er.en); }
    | el=expr op='||' er=expr { $en = new Or($el.en, $er.en); }
    | FLOAT { $en = new Const(new BigDecimal($FLOAT.text)); }
    | ID    { $en = new Var($ID.text); }
    | ID '(' { ArrayList<ExprNode> args = new ArrayList<ExprNode>(); $en = new Func($ID.text, args);} (arg=expr  {args.add($arg.en); } (',' next=expr {args.add($next.en); System.out.println("Test!");})*)?  // not working
    ;

func returns [ExprNode en] :
    //'read()'  { $i = new BigDecimal(input.nextLine().trim()); }  worry about this later }
    
    ;

/* Lexer rules */
ID: [_A-Za-z]+;
FLOAT: [0-9]*[.]?[0-9]+; 
STRING: ["].*?["]; /* lazy definition of string */
WS : [ \t]+ -> skip ;
C_COMMENT: [/][*](.)*?[*][/] -> skip;
P_COMMENT: '#' (.)*? ENDLINE -> skip;
ENDLINE: '\r'?'\n';
SEMI: ';';
COMMA: ',';