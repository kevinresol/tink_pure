package tink.pure;

#if macro
  import haxe.macro.Context.*;
  using haxe.macro.Tools;
#end

@:forward(length, indexOf, contains, iterator, keyValueIterator, join)
@:pure
@:jsonParse(a -> @:privateAccess new tink.pure.Vector(a))
@:jsonStringify(vec -> @:privateAccess vec.unwrap())
abstract Vector<T>(Array<T>) to Vectorlike<T> {

  inline function new(a)
    this = a;

  inline function unwrap()
    return this;

  @:arrayAccess
  public inline function get(index)
    return this[index];

  public inline function map<R>(f:T->R)
    return new Vector(this.map(f));

  public inline function filter(f:T->Bool)
    return new Vector(this.filter(f));

  public inline function sorted(compare:(T, T)->Int) {
    var a = this.copy();
    a.sort(compare);
    return new Vector(a);
  }
  
  public inline function slice(pos, end)
    return new Vector(this.slice(pos, end));
  
  public inline function exists(f)
    return Lambda.exists(this, f);
  
  public inline function find(f)
    return Lambda.find(this, f);
  
  public inline function fold<R>(f:(v:T, result:R)->R, init:R)
    return Lambda.fold(this, f, init);
  
  public inline function with(index:Int, value:T):Vector<T> {
    final arr = this.copy();
    arr[index] = value;
    return new Vector(arr);
  }

  @:op(a & b)
  public inline function concat(that:Vectorlike<T>)
    return new Vector(this.concat(cast that));

  @:op(a & b)
  static inline function lconcat<T>(a:Vectorlike<T>, b:Vector<T>)
    return new Vector(a.concat(b.unwrap()));
  
  static public inline function empty<T>():Vector<T> {
    return new Vector<T>([]);
  }

  @:from static function fromVector<T>(v:Vector<T>):Vector<T>
    return cast v;

  #if macro @:from #end
  static public inline function fromArray<T>(a:Array<T>)
    return new Vector<T>(cast a.copy());

  #if macro @:from #end
  static public inline function fromMutable<T>(v:haxe.ds.Vector<T>)
    return new Vector<T>(cast v.toArray());

  #if macro @:from #end
  static public inline function fromIterable<T>(v:Iterable<T>)
    return new Vector<T>([for (x in v) x]);

  @:to public inline function toArray()
    return this.copy();

  @:from macro static function ofAny(e) {
    var t = typeExpr(e);
    e = storeTypedExpr(t);
    return switch t.expr {
      case TArrayDecl(_):
        macro @:pos(e.pos) @:privateAccess new tink.pure.Vector(${e});
      case TBlock([ // this is how the compiler transforms array comprehension syntax into typed exprs
          {expr: TVar({id: initId, name: name}, {expr: TArrayDecl([])})},
          {expr: TBlock(exprs)},
          {expr: TLocal({id: retId})},
      ]) if(initId == retId && name.charCodeAt(0) == '`'.code):
        macro @:pos(e.pos) @:privateAccess new tink.pure.Vector(${e});
      default:
        switch follow(t.t) {
          case TInst(_.get() => { pack: [], name: 'Array' }, _):
            macro @:pos(e.pos) tink.pure.Vector.fromArray(${e});
          case TAbstract(_.get() => { pack: ['haxe', 'ds'], name: 'Vector' }, _):
            macro @:pos(e.pos) tink.pure.Vector.fromMutable(${e});
          default:
            macro @:pos(e.pos) tink.pure.Vector.fromIterable(${e});
        }
    }
  }
}

@:forward
private abstract Vectorlike<T>(Array<T>) from Array<T> {
  @:from static function ofSingle<T>(v:T):Vectorlike<T>
    return [v];
}
