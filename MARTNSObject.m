
#import "MARTNSObject.h"

#import <objc/runtime.h>

#import "MARuntime.h"
#import "RTProtocol.h"
#import "RTIvar.h"
#import "RTProperty.h"
#import "RTMethod.h"
#import "RTUnregisteredClass.h"


@implementation NSObject (MARuntime)

+ (NSArray *)rt_subclasses
{
    NSMutableArray *array = [NSMutableArray array];
    for(Class candidate in [MARuntime classes])
    {
        if(class_getSuperclass(candidate) == self)
        {
            [array addObject: candidate];
        }
    }
    return array;
}

+ (RTUnregisteredClass *)rt_createUnregisteredSubclassNamed: (NSString *)name
{
    return [RTUnregisteredClass unregisteredClassWithName: name withSuperclass: self];
}

+ (Class)rt_createSubclassNamed: (NSString *)name
{
    return [[self rt_createUnregisteredSubclassNamed: name] registerClass];
}

+ (void)rt_destroyClass
{
    objc_disposeClassPair(self);
}

+ (BOOL)rt_isMetaClass
{
    return class_isMetaClass(self);
}

#ifdef __clang__
#pragma clang diagnostic push
#endif
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (Class)rt_setSuperclass: (Class)newSuperclass
{
    return class_setSuperclass(self, newSuperclass);
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif

+ (size_t)rt_instanceSize
{
    return class_getInstanceSize(self);
}

+ (NSArray *)rt_protocols
{
    unsigned int count;
    Protocol **protocols = class_copyProtocolList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTProtocol protocolWithObjCProtocol: protocols[i]]];
    
    free(protocols);
    return array;
}

+ (NSArray *)rt_methods
{
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTMethod methodWithObjCMethod: methods[i]]];
    
    free(methods);
    return array;
}

+ (RTMethod *)rt_methodForSelector: (SEL)sel
{
    Method m = class_getInstanceMethod(self, sel);
    if(!m) return nil;
    
    return [RTMethod methodWithObjCMethod: m];
}

+ (void)rt_addMethod: (RTMethod *)method
{
    class_addMethod(self, [method selector], [method implementation], [[method signature] UTF8String]);
}

+ (NSArray *)rt_ivars
{
    unsigned int count;
    Ivar *list = class_copyIvarList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTIvar ivarWithObjCIvar: list[i]]];
    
    free(list);
    return array;
}

+ (RTIvar *)rt_ivarForName: (NSString *)name
{
    Ivar ivar = class_getInstanceVariable(self, [name UTF8String]);
    if(!ivar) return nil;
    return [RTIvar ivarWithObjCIvar: ivar];
}

+ (NSArray *)rt_properties
{
    unsigned int count;
    objc_property_t *list = class_copyPropertyList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTProperty propertyWithObjCProperty: list[i]]];
    
    free(list);
    return array;
}

+ (RTProperty *)rt_propertyForName: (NSString *)name
{
    objc_property_t property = class_getProperty(self, [name UTF8String]);
    if(!property) return nil;
    return [RTProperty propertyWithObjCProperty: property];
}

- (Class)rt_class
{
    return object_getClass(self);
}

- (Class)rt_setClass: (Class)newClass
{
    return object_setClass(self, newClass);
}

@end

