
obj/user/buggyhello.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 e8 04 00 00       	call   800580 <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 6a 22 80 00       	push   $0x80226a
  800111:	6a 23                	push   $0x23
  800113:	68 87 22 80 00       	push   $0x802287
  800118:	e8 dc 13 00 00       	call   8014f9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 6a 22 80 00       	push   $0x80226a
  800192:	6a 23                	push   $0x23
  800194:	68 87 22 80 00       	push   $0x802287
  800199:	e8 5b 13 00 00       	call   8014f9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 6a 22 80 00       	push   $0x80226a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 87 22 80 00       	push   $0x802287
  8001db:	e8 19 13 00 00       	call   8014f9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 6a 22 80 00       	push   $0x80226a
  800216:	6a 23                	push   $0x23
  800218:	68 87 22 80 00       	push   $0x802287
  80021d:	e8 d7 12 00 00       	call   8014f9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 6a 22 80 00       	push   $0x80226a
  800258:	6a 23                	push   $0x23
  80025a:	68 87 22 80 00       	push   $0x802287
  80025f:	e8 95 12 00 00       	call   8014f9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 6a 22 80 00       	push   $0x80226a
  80029a:	6a 23                	push   $0x23
  80029c:	68 87 22 80 00       	push   $0x802287
  8002a1:	e8 53 12 00 00       	call   8014f9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 6a 22 80 00       	push   $0x80226a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 87 22 80 00       	push   $0x802287
  8002e3:	e8 11 12 00 00       	call   8014f9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 6a 22 80 00       	push   $0x80226a
  800340:	6a 23                	push   $0x23
  800342:	68 87 22 80 00       	push   $0x802287
  800347:	e8 ad 11 00 00       	call   8014f9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800381:	b8 0f 00 00 00       	mov    $0xf,%eax
  800386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	89 df                	mov    %ebx,%edi
  80038e:	89 de                	mov    %ebx,%esi
  800390:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800392:	85 c0                	test   %eax,%eax
  800394:	7e 17                	jle    8003ad <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	50                   	push   %eax
  80039a:	6a 0f                	push   $0xf
  80039c:	68 6a 22 80 00       	push   $0x80226a
  8003a1:	6a 23                	push   $0x23
  8003a3:	68 87 22 80 00       	push   $0x802287
  8003a8:	e8 4c 11 00 00       	call   8014f9 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	05 00 00 00 30       	add    $0x30000000,%eax
  8003d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e7:	89 c2                	mov    %eax,%edx
  8003e9:	c1 ea 16             	shr    $0x16,%edx
  8003ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f3:	f6 c2 01             	test   $0x1,%dl
  8003f6:	74 11                	je     800409 <fd_alloc+0x2d>
  8003f8:	89 c2                	mov    %eax,%edx
  8003fa:	c1 ea 0c             	shr    $0xc,%edx
  8003fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800404:	f6 c2 01             	test   $0x1,%dl
  800407:	75 09                	jne    800412 <fd_alloc+0x36>
			*fd_store = fd;
  800409:	89 01                	mov    %eax,(%ecx)
			return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 17                	jmp    800429 <fd_alloc+0x4d>
  800412:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800417:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80041c:	75 c9                	jne    8003e7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80041e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800424:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800431:	83 f8 1f             	cmp    $0x1f,%eax
  800434:	77 36                	ja     80046c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800436:	c1 e0 0c             	shl    $0xc,%eax
  800439:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043e:	89 c2                	mov    %eax,%edx
  800440:	c1 ea 16             	shr    $0x16,%edx
  800443:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80044a:	f6 c2 01             	test   $0x1,%dl
  80044d:	74 24                	je     800473 <fd_lookup+0x48>
  80044f:	89 c2                	mov    %eax,%edx
  800451:	c1 ea 0c             	shr    $0xc,%edx
  800454:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045b:	f6 c2 01             	test   $0x1,%dl
  80045e:	74 1a                	je     80047a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800460:	8b 55 0c             	mov    0xc(%ebp),%edx
  800463:	89 02                	mov    %eax,(%edx)
	return 0;
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	eb 13                	jmp    80047f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800471:	eb 0c                	jmp    80047f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800478:	eb 05                	jmp    80047f <fd_lookup+0x54>
  80047a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80047f:	5d                   	pop    %ebp
  800480:	c3                   	ret    

00800481 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800481:	55                   	push   %ebp
  800482:	89 e5                	mov    %esp,%ebp
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048a:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048f:	eb 13                	jmp    8004a4 <dev_lookup+0x23>
  800491:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800494:	39 08                	cmp    %ecx,(%eax)
  800496:	75 0c                	jne    8004a4 <dev_lookup+0x23>
			*dev = devtab[i];
  800498:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80049b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	eb 2e                	jmp    8004d2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004a4:	8b 02                	mov    (%edx),%eax
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	75 e7                	jne    800491 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8004af:	8b 40 48             	mov    0x48(%eax),%eax
  8004b2:	83 ec 04             	sub    $0x4,%esp
  8004b5:	51                   	push   %ecx
  8004b6:	50                   	push   %eax
  8004b7:	68 98 22 80 00       	push   $0x802298
  8004bc:	e8 11 11 00 00       	call   8015d2 <cprintf>
	*dev = 0;
  8004c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	56                   	push   %esi
  8004d8:	53                   	push   %ebx
  8004d9:	83 ec 10             	sub    $0x10,%esp
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e5:	50                   	push   %eax
  8004e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ec:	c1 e8 0c             	shr    $0xc,%eax
  8004ef:	50                   	push   %eax
  8004f0:	e8 36 ff ff ff       	call   80042b <fd_lookup>
  8004f5:	83 c4 08             	add    $0x8,%esp
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	78 05                	js     800501 <fd_close+0x2d>
	    || fd != fd2)
  8004fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ff:	74 0c                	je     80050d <fd_close+0x39>
		return (must_exist ? r : 0);
  800501:	84 db                	test   %bl,%bl
  800503:	ba 00 00 00 00       	mov    $0x0,%edx
  800508:	0f 44 c2             	cmove  %edx,%eax
  80050b:	eb 41                	jmp    80054e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	ff 36                	pushl  (%esi)
  800516:	e8 66 ff ff ff       	call   800481 <dev_lookup>
  80051b:	89 c3                	mov    %eax,%ebx
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	85 c0                	test   %eax,%eax
  800522:	78 1a                	js     80053e <fd_close+0x6a>
		if (dev->dev_close)
  800524:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800527:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80052a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80052f:	85 c0                	test   %eax,%eax
  800531:	74 0b                	je     80053e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800533:	83 ec 0c             	sub    $0xc,%esp
  800536:	56                   	push   %esi
  800537:	ff d0                	call   *%eax
  800539:	89 c3                	mov    %eax,%ebx
  80053b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	56                   	push   %esi
  800542:	6a 00                	push   $0x0
  800544:	e8 9f fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	89 d8                	mov    %ebx,%eax
}
  80054e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800551:	5b                   	pop    %ebx
  800552:	5e                   	pop    %esi
  800553:	5d                   	pop    %ebp
  800554:	c3                   	ret    

00800555 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80055b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055e:	50                   	push   %eax
  80055f:	ff 75 08             	pushl  0x8(%ebp)
  800562:	e8 c4 fe ff ff       	call   80042b <fd_lookup>
  800567:	83 c4 08             	add    $0x8,%esp
  80056a:	85 c0                	test   %eax,%eax
  80056c:	78 10                	js     80057e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	6a 01                	push   $0x1
  800573:	ff 75 f4             	pushl  -0xc(%ebp)
  800576:	e8 59 ff ff ff       	call   8004d4 <fd_close>
  80057b:	83 c4 10             	add    $0x10,%esp
}
  80057e:	c9                   	leave  
  80057f:	c3                   	ret    

00800580 <close_all>:

void
close_all(void)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	53                   	push   %ebx
  800584:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800587:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	53                   	push   %ebx
  800590:	e8 c0 ff ff ff       	call   800555 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800595:	83 c3 01             	add    $0x1,%ebx
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	83 fb 20             	cmp    $0x20,%ebx
  80059e:	75 ec                	jne    80058c <close_all+0xc>
		close(i);
}
  8005a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a3:	c9                   	leave  
  8005a4:	c3                   	ret    

008005a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
  8005a8:	57                   	push   %edi
  8005a9:	56                   	push   %esi
  8005aa:	53                   	push   %ebx
  8005ab:	83 ec 2c             	sub    $0x2c,%esp
  8005ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b4:	50                   	push   %eax
  8005b5:	ff 75 08             	pushl  0x8(%ebp)
  8005b8:	e8 6e fe ff ff       	call   80042b <fd_lookup>
  8005bd:	83 c4 08             	add    $0x8,%esp
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	0f 88 c1 00 00 00    	js     800689 <dup+0xe4>
		return r;
	close(newfdnum);
  8005c8:	83 ec 0c             	sub    $0xc,%esp
  8005cb:	56                   	push   %esi
  8005cc:	e8 84 ff ff ff       	call   800555 <close>

	newfd = INDEX2FD(newfdnum);
  8005d1:	89 f3                	mov    %esi,%ebx
  8005d3:	c1 e3 0c             	shl    $0xc,%ebx
  8005d6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005dc:	83 c4 04             	add    $0x4,%esp
  8005df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e2:	e8 de fd ff ff       	call   8003c5 <fd2data>
  8005e7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005e9:	89 1c 24             	mov    %ebx,(%esp)
  8005ec:	e8 d4 fd ff ff       	call   8003c5 <fd2data>
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f7:	89 f8                	mov    %edi,%eax
  8005f9:	c1 e8 16             	shr    $0x16,%eax
  8005fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800603:	a8 01                	test   $0x1,%al
  800605:	74 37                	je     80063e <dup+0x99>
  800607:	89 f8                	mov    %edi,%eax
  800609:	c1 e8 0c             	shr    $0xc,%eax
  80060c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800613:	f6 c2 01             	test   $0x1,%dl
  800616:	74 26                	je     80063e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800618:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061f:	83 ec 0c             	sub    $0xc,%esp
  800622:	25 07 0e 00 00       	and    $0xe07,%eax
  800627:	50                   	push   %eax
  800628:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062b:	6a 00                	push   $0x0
  80062d:	57                   	push   %edi
  80062e:	6a 00                	push   $0x0
  800630:	e8 71 fb ff ff       	call   8001a6 <sys_page_map>
  800635:	89 c7                	mov    %eax,%edi
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	78 2e                	js     80066c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800641:	89 d0                	mov    %edx,%eax
  800643:	c1 e8 0c             	shr    $0xc,%eax
  800646:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	25 07 0e 00 00       	and    $0xe07,%eax
  800655:	50                   	push   %eax
  800656:	53                   	push   %ebx
  800657:	6a 00                	push   $0x0
  800659:	52                   	push   %edx
  80065a:	6a 00                	push   $0x0
  80065c:	e8 45 fb ff ff       	call   8001a6 <sys_page_map>
  800661:	89 c7                	mov    %eax,%edi
  800663:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800666:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800668:	85 ff                	test   %edi,%edi
  80066a:	79 1d                	jns    800689 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 00                	push   $0x0
  800672:	e8 71 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80067d:	6a 00                	push   $0x0
  80067f:	e8 64 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	89 f8                	mov    %edi,%eax
}
  800689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068c:	5b                   	pop    %ebx
  80068d:	5e                   	pop    %esi
  80068e:	5f                   	pop    %edi
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	53                   	push   %ebx
  800695:	83 ec 14             	sub    $0x14,%esp
  800698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80069b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	53                   	push   %ebx
  8006a0:	e8 86 fd ff ff       	call   80042b <fd_lookup>
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	78 6d                	js     80071b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b8:	ff 30                	pushl  (%eax)
  8006ba:	e8 c2 fd ff ff       	call   800481 <dev_lookup>
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	78 4c                	js     800712 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006c9:	8b 42 08             	mov    0x8(%edx),%eax
  8006cc:	83 e0 03             	and    $0x3,%eax
  8006cf:	83 f8 01             	cmp    $0x1,%eax
  8006d2:	75 21                	jne    8006f5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8006d9:	8b 40 48             	mov    0x48(%eax),%eax
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	53                   	push   %ebx
  8006e0:	50                   	push   %eax
  8006e1:	68 d9 22 80 00       	push   $0x8022d9
  8006e6:	e8 e7 0e 00 00       	call   8015d2 <cprintf>
		return -E_INVAL;
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006f3:	eb 26                	jmp    80071b <read+0x8a>
	}
	if (!dev->dev_read)
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	8b 40 08             	mov    0x8(%eax),%eax
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	74 17                	je     800716 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ff:	83 ec 04             	sub    $0x4,%esp
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	52                   	push   %edx
  800709:	ff d0                	call   *%eax
  80070b:	89 c2                	mov    %eax,%edx
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb 09                	jmp    80071b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800712:	89 c2                	mov    %eax,%edx
  800714:	eb 05                	jmp    80071b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800716:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80071b:	89 d0                	mov    %edx,%eax
  80071d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	57                   	push   %edi
  800726:	56                   	push   %esi
  800727:	53                   	push   %ebx
  800728:	83 ec 0c             	sub    $0xc,%esp
  80072b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800731:	bb 00 00 00 00       	mov    $0x0,%ebx
  800736:	eb 21                	jmp    800759 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800738:	83 ec 04             	sub    $0x4,%esp
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	29 d8                	sub    %ebx,%eax
  80073f:	50                   	push   %eax
  800740:	89 d8                	mov    %ebx,%eax
  800742:	03 45 0c             	add    0xc(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	57                   	push   %edi
  800747:	e8 45 ff ff ff       	call   800691 <read>
		if (m < 0)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	85 c0                	test   %eax,%eax
  800751:	78 10                	js     800763 <readn+0x41>
			return m;
		if (m == 0)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 0a                	je     800761 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800757:	01 c3                	add    %eax,%ebx
  800759:	39 f3                	cmp    %esi,%ebx
  80075b:	72 db                	jb     800738 <readn+0x16>
  80075d:	89 d8                	mov    %ebx,%eax
  80075f:	eb 02                	jmp    800763 <readn+0x41>
  800761:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	83 ec 14             	sub    $0x14,%esp
  800772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800775:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	53                   	push   %ebx
  80077a:	e8 ac fc ff ff       	call   80042b <fd_lookup>
  80077f:	83 c4 08             	add    $0x8,%esp
  800782:	89 c2                	mov    %eax,%edx
  800784:	85 c0                	test   %eax,%eax
  800786:	78 68                	js     8007f0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078e:	50                   	push   %eax
  80078f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800792:	ff 30                	pushl  (%eax)
  800794:	e8 e8 fc ff ff       	call   800481 <dev_lookup>
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	85 c0                	test   %eax,%eax
  80079e:	78 47                	js     8007e7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007a7:	75 21                	jne    8007ca <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8007ae:	8b 40 48             	mov    0x48(%eax),%eax
  8007b1:	83 ec 04             	sub    $0x4,%esp
  8007b4:	53                   	push   %ebx
  8007b5:	50                   	push   %eax
  8007b6:	68 f5 22 80 00       	push   $0x8022f5
  8007bb:	e8 12 0e 00 00       	call   8015d2 <cprintf>
		return -E_INVAL;
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007c8:	eb 26                	jmp    8007f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 17                	je     8007eb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007d4:	83 ec 04             	sub    $0x4,%esp
  8007d7:	ff 75 10             	pushl  0x10(%ebp)
  8007da:	ff 75 0c             	pushl  0xc(%ebp)
  8007dd:	50                   	push   %eax
  8007de:	ff d2                	call   *%edx
  8007e0:	89 c2                	mov    %eax,%edx
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	eb 09                	jmp    8007f0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	eb 05                	jmp    8007f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007f0:	89 d0                	mov    %edx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	ff 75 08             	pushl  0x8(%ebp)
  800804:	e8 22 fc ff ff       	call   80042b <fd_lookup>
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	85 c0                	test   %eax,%eax
  80080e:	78 0e                	js     80081e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800810:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 14             	sub    $0x14,%esp
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082d:	50                   	push   %eax
  80082e:	53                   	push   %ebx
  80082f:	e8 f7 fb ff ff       	call   80042b <fd_lookup>
  800834:	83 c4 08             	add    $0x8,%esp
  800837:	89 c2                	mov    %eax,%edx
  800839:	85 c0                	test   %eax,%eax
  80083b:	78 65                	js     8008a2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800847:	ff 30                	pushl  (%eax)
  800849:	e8 33 fc ff ff       	call   800481 <dev_lookup>
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 44                	js     800899 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800858:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80085c:	75 21                	jne    80087f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80085e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800863:	8b 40 48             	mov    0x48(%eax),%eax
  800866:	83 ec 04             	sub    $0x4,%esp
  800869:	53                   	push   %ebx
  80086a:	50                   	push   %eax
  80086b:	68 b8 22 80 00       	push   $0x8022b8
  800870:	e8 5d 0d 00 00       	call   8015d2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80087d:	eb 23                	jmp    8008a2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80087f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800882:	8b 52 18             	mov    0x18(%edx),%edx
  800885:	85 d2                	test   %edx,%edx
  800887:	74 14                	je     80089d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	ff 75 0c             	pushl  0xc(%ebp)
  80088f:	50                   	push   %eax
  800890:	ff d2                	call   *%edx
  800892:	89 c2                	mov    %eax,%edx
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	eb 09                	jmp    8008a2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800899:	89 c2                	mov    %eax,%edx
  80089b:	eb 05                	jmp    8008a2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80089d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008a2:	89 d0                	mov    %edx,%eax
  8008a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	83 ec 14             	sub    $0x14,%esp
  8008b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 6c fb ff ff       	call   80042b <fd_lookup>
  8008bf:	83 c4 08             	add    $0x8,%esp
  8008c2:	89 c2                	mov    %eax,%edx
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	78 58                	js     800920 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ce:	50                   	push   %eax
  8008cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d2:	ff 30                	pushl  (%eax)
  8008d4:	e8 a8 fb ff ff       	call   800481 <dev_lookup>
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 37                	js     800917 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e7:	74 32                	je     80091b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f3:	00 00 00 
	stat->st_isdir = 0;
  8008f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008fd:	00 00 00 
	stat->st_dev = dev;
  800900:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	ff 75 f0             	pushl  -0x10(%ebp)
  80090d:	ff 50 14             	call   *0x14(%eax)
  800910:	89 c2                	mov    %eax,%edx
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb 09                	jmp    800920 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800917:	89 c2                	mov    %eax,%edx
  800919:	eb 05                	jmp    800920 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80091b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800920:	89 d0                	mov    %edx,%eax
  800922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	6a 00                	push   $0x0
  800931:	ff 75 08             	pushl  0x8(%ebp)
  800934:	e8 d6 01 00 00       	call   800b0f <open>
  800939:	89 c3                	mov    %eax,%ebx
  80093b:	83 c4 10             	add    $0x10,%esp
  80093e:	85 c0                	test   %eax,%eax
  800940:	78 1b                	js     80095d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800942:	83 ec 08             	sub    $0x8,%esp
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	50                   	push   %eax
  800949:	e8 5b ff ff ff       	call   8008a9 <fstat>
  80094e:	89 c6                	mov    %eax,%esi
	close(fd);
  800950:	89 1c 24             	mov    %ebx,(%esp)
  800953:	e8 fd fb ff ff       	call   800555 <close>
	return r;
  800958:	83 c4 10             	add    $0x10,%esp
  80095b:	89 f0                	mov    %esi,%eax
}
  80095d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	89 c6                	mov    %eax,%esi
  80096b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80096d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800974:	75 12                	jne    800988 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800976:	83 ec 0c             	sub    $0xc,%esp
  800979:	6a 01                	push   $0x1
  80097b:	e8 d9 15 00 00       	call   801f59 <ipc_find_env>
  800980:	a3 00 40 80 00       	mov    %eax,0x804000
  800985:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800988:	6a 07                	push   $0x7
  80098a:	68 00 50 80 00       	push   $0x805000
  80098f:	56                   	push   %esi
  800990:	ff 35 00 40 80 00    	pushl  0x804000
  800996:	e8 6a 15 00 00       	call   801f05 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80099b:	83 c4 0c             	add    $0xc,%esp
  80099e:	6a 00                	push   $0x0
  8009a0:	53                   	push   %ebx
  8009a1:	6a 00                	push   $0x0
  8009a3:	e8 f6 14 00 00       	call   801e9e <ipc_recv>
}
  8009a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d2:	e8 8d ff ff ff       	call   800964 <fsipc>
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f4:	e8 6b ff ff ff       	call   800964 <fsipc>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 04             	sub    $0x4,%esp
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a10:	ba 00 00 00 00       	mov    $0x0,%edx
  800a15:	b8 05 00 00 00       	mov    $0x5,%eax
  800a1a:	e8 45 ff ff ff       	call   800964 <fsipc>
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	78 2c                	js     800a4f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	68 00 50 80 00       	push   $0x805000
  800a2b:	53                   	push   %ebx
  800a2c:	e8 26 11 00 00       	call   801b57 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a31:	a1 80 50 80 00       	mov    0x805080,%eax
  800a36:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a3c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a41:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 0c             	sub    $0xc,%esp
  800a5a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	8b 52 0c             	mov    0xc(%edx),%edx
  800a63:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a69:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a6e:	50                   	push   %eax
  800a6f:	ff 75 0c             	pushl  0xc(%ebp)
  800a72:	68 08 50 80 00       	push   $0x805008
  800a77:	e8 6d 12 00 00       	call   801ce9 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a81:	b8 04 00 00 00       	mov    $0x4,%eax
  800a86:	e8 d9 fe ff ff       	call   800964 <fsipc>

}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	e8 af fe ff ff       	call   800964 <fsipc>
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	78 4b                	js     800b06 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800abb:	39 c6                	cmp    %eax,%esi
  800abd:	73 16                	jae    800ad5 <devfile_read+0x48>
  800abf:	68 28 23 80 00       	push   $0x802328
  800ac4:	68 2f 23 80 00       	push   $0x80232f
  800ac9:	6a 7c                	push   $0x7c
  800acb:	68 44 23 80 00       	push   $0x802344
  800ad0:	e8 24 0a 00 00       	call   8014f9 <_panic>
	assert(r <= PGSIZE);
  800ad5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ada:	7e 16                	jle    800af2 <devfile_read+0x65>
  800adc:	68 4f 23 80 00       	push   $0x80234f
  800ae1:	68 2f 23 80 00       	push   $0x80232f
  800ae6:	6a 7d                	push   $0x7d
  800ae8:	68 44 23 80 00       	push   $0x802344
  800aed:	e8 07 0a 00 00       	call   8014f9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af2:	83 ec 04             	sub    $0x4,%esp
  800af5:	50                   	push   %eax
  800af6:	68 00 50 80 00       	push   $0x805000
  800afb:	ff 75 0c             	pushl  0xc(%ebp)
  800afe:	e8 e6 11 00 00       	call   801ce9 <memmove>
	return r;
  800b03:	83 c4 10             	add    $0x10,%esp
}
  800b06:	89 d8                	mov    %ebx,%eax
  800b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	53                   	push   %ebx
  800b13:	83 ec 20             	sub    $0x20,%esp
  800b16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b19:	53                   	push   %ebx
  800b1a:	e8 ff 0f 00 00       	call   801b1e <strlen>
  800b1f:	83 c4 10             	add    $0x10,%esp
  800b22:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b27:	7f 67                	jg     800b90 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2f:	50                   	push   %eax
  800b30:	e8 a7 f8 ff ff       	call   8003dc <fd_alloc>
  800b35:	83 c4 10             	add    $0x10,%esp
		return r;
  800b38:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 57                	js     800b95 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	53                   	push   %ebx
  800b42:	68 00 50 80 00       	push   $0x805000
  800b47:	e8 0b 10 00 00       	call   801b57 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b57:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5c:	e8 03 fe ff ff       	call   800964 <fsipc>
  800b61:	89 c3                	mov    %eax,%ebx
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	85 c0                	test   %eax,%eax
  800b68:	79 14                	jns    800b7e <open+0x6f>
		fd_close(fd, 0);
  800b6a:	83 ec 08             	sub    $0x8,%esp
  800b6d:	6a 00                	push   $0x0
  800b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b72:	e8 5d f9 ff ff       	call   8004d4 <fd_close>
		return r;
  800b77:	83 c4 10             	add    $0x10,%esp
  800b7a:	89 da                	mov    %ebx,%edx
  800b7c:	eb 17                	jmp    800b95 <open+0x86>
	}

	return fd2num(fd);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	ff 75 f4             	pushl  -0xc(%ebp)
  800b84:	e8 2c f8 ff ff       	call   8003b5 <fd2num>
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	eb 05                	jmp    800b95 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b90:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b95:	89 d0                	mov    %edx,%eax
  800b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bac:	e8 b3 fd ff ff       	call   800964 <fsipc>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bb9:	68 5b 23 80 00       	push   $0x80235b
  800bbe:	ff 75 0c             	pushl  0xc(%ebp)
  800bc1:	e8 91 0f 00 00       	call   801b57 <strcpy>
	return 0;
}
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 10             	sub    $0x10,%esp
  800bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bd7:	53                   	push   %ebx
  800bd8:	e8 b5 13 00 00       	call   801f92 <pageref>
  800bdd:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800be5:	83 f8 01             	cmp    $0x1,%eax
  800be8:	75 10                	jne    800bfa <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	ff 73 0c             	pushl  0xc(%ebx)
  800bf0:	e8 c0 02 00 00       	call   800eb5 <nsipc_close>
  800bf5:	89 c2                	mov    %eax,%edx
  800bf7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bfa:	89 d0                	mov    %edx,%eax
  800bfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c07:	6a 00                	push   $0x0
  800c09:	ff 75 10             	pushl  0x10(%ebp)
  800c0c:	ff 75 0c             	pushl  0xc(%ebp)
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	ff 70 0c             	pushl  0xc(%eax)
  800c15:	e8 78 03 00 00       	call   800f92 <nsipc_send>
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c22:	6a 00                	push   $0x0
  800c24:	ff 75 10             	pushl  0x10(%ebp)
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	ff 70 0c             	pushl  0xc(%eax)
  800c30:	e8 f1 02 00 00       	call   800f26 <nsipc_recv>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c3d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c40:	52                   	push   %edx
  800c41:	50                   	push   %eax
  800c42:	e8 e4 f7 ff ff       	call   80042b <fd_lookup>
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	78 17                	js     800c65 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c51:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c57:	39 08                	cmp    %ecx,(%eax)
  800c59:	75 05                	jne    800c60 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c5b:	8b 40 0c             	mov    0xc(%eax),%eax
  800c5e:	eb 05                	jmp    800c65 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c60:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 1c             	sub    $0x1c,%esp
  800c6f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c74:	50                   	push   %eax
  800c75:	e8 62 f7 ff ff       	call   8003dc <fd_alloc>
  800c7a:	89 c3                	mov    %eax,%ebx
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	78 1b                	js     800c9e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c83:	83 ec 04             	sub    $0x4,%esp
  800c86:	68 07 04 00 00       	push   $0x407
  800c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800c8e:	6a 00                	push   $0x0
  800c90:	e8 ce f4 ff ff       	call   800163 <sys_page_alloc>
  800c95:	89 c3                	mov    %eax,%ebx
  800c97:	83 c4 10             	add    $0x10,%esp
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	79 10                	jns    800cae <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	56                   	push   %esi
  800ca2:	e8 0e 02 00 00       	call   800eb5 <nsipc_close>
		return r;
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	89 d8                	mov    %ebx,%eax
  800cac:	eb 24                	jmp    800cd2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cc3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	e8 e6 f6 ff ff       	call   8003b5 <fd2num>
  800ccf:	83 c4 10             	add    $0x10,%esp
}
  800cd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	e8 50 ff ff ff       	call   800c37 <fd2sockid>
		return r;
  800ce7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	78 1f                	js     800d0c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ced:	83 ec 04             	sub    $0x4,%esp
  800cf0:	ff 75 10             	pushl  0x10(%ebp)
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	50                   	push   %eax
  800cf7:	e8 12 01 00 00       	call   800e0e <nsipc_accept>
  800cfc:	83 c4 10             	add    $0x10,%esp
		return r;
  800cff:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	78 07                	js     800d0c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d05:	e8 5d ff ff ff       	call   800c67 <alloc_sockfd>
  800d0a:	89 c1                	mov    %eax,%ecx
}
  800d0c:	89 c8                	mov    %ecx,%eax
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	e8 19 ff ff ff       	call   800c37 <fd2sockid>
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	78 12                	js     800d34 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	ff 75 10             	pushl  0x10(%ebp)
  800d28:	ff 75 0c             	pushl  0xc(%ebp)
  800d2b:	50                   	push   %eax
  800d2c:	e8 2d 01 00 00       	call   800e5e <nsipc_bind>
  800d31:	83 c4 10             	add    $0x10,%esp
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <shutdown>:

int
shutdown(int s, int how)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	e8 f3 fe ff ff       	call   800c37 <fd2sockid>
  800d44:	85 c0                	test   %eax,%eax
  800d46:	78 0f                	js     800d57 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d48:	83 ec 08             	sub    $0x8,%esp
  800d4b:	ff 75 0c             	pushl  0xc(%ebp)
  800d4e:	50                   	push   %eax
  800d4f:	e8 3f 01 00 00       	call   800e93 <nsipc_shutdown>
  800d54:	83 c4 10             	add    $0x10,%esp
}
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	e8 d0 fe ff ff       	call   800c37 <fd2sockid>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 12                	js     800d7d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d6b:	83 ec 04             	sub    $0x4,%esp
  800d6e:	ff 75 10             	pushl  0x10(%ebp)
  800d71:	ff 75 0c             	pushl  0xc(%ebp)
  800d74:	50                   	push   %eax
  800d75:	e8 55 01 00 00       	call   800ecf <nsipc_connect>
  800d7a:	83 c4 10             	add    $0x10,%esp
}
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <listen>:

int
listen(int s, int backlog)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	e8 aa fe ff ff       	call   800c37 <fd2sockid>
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	78 0f                	js     800da0 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	ff 75 0c             	pushl  0xc(%ebp)
  800d97:	50                   	push   %eax
  800d98:	e8 67 01 00 00       	call   800f04 <nsipc_listen>
  800d9d:	83 c4 10             	add    $0x10,%esp
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800da8:	ff 75 10             	pushl  0x10(%ebp)
  800dab:	ff 75 0c             	pushl  0xc(%ebp)
  800dae:	ff 75 08             	pushl  0x8(%ebp)
  800db1:	e8 3a 02 00 00       	call   800ff0 <nsipc_socket>
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	78 05                	js     800dc2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dbd:	e8 a5 fe ff ff       	call   800c67 <alloc_sockfd>
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dcd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dd4:	75 12                	jne    800de8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	6a 02                	push   $0x2
  800ddb:	e8 79 11 00 00       	call   801f59 <ipc_find_env>
  800de0:	a3 04 40 80 00       	mov    %eax,0x804004
  800de5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800de8:	6a 07                	push   $0x7
  800dea:	68 00 60 80 00       	push   $0x806000
  800def:	53                   	push   %ebx
  800df0:	ff 35 04 40 80 00    	pushl  0x804004
  800df6:	e8 0a 11 00 00       	call   801f05 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dfb:	83 c4 0c             	add    $0xc,%esp
  800dfe:	6a 00                	push   $0x0
  800e00:	6a 00                	push   $0x0
  800e02:	6a 00                	push   $0x0
  800e04:	e8 95 10 00 00       	call   801e9e <ipc_recv>
}
  800e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e0c:	c9                   	leave  
  800e0d:	c3                   	ret    

00800e0e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e1e:	8b 06                	mov    (%esi),%eax
  800e20:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e25:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2a:	e8 95 ff ff ff       	call   800dc4 <nsipc>
  800e2f:	89 c3                	mov    %eax,%ebx
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 20                	js     800e55 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e35:	83 ec 04             	sub    $0x4,%esp
  800e38:	ff 35 10 60 80 00    	pushl  0x806010
  800e3e:	68 00 60 80 00       	push   $0x806000
  800e43:	ff 75 0c             	pushl  0xc(%ebp)
  800e46:	e8 9e 0e 00 00       	call   801ce9 <memmove>
		*addrlen = ret->ret_addrlen;
  800e4b:	a1 10 60 80 00       	mov    0x806010,%eax
  800e50:	89 06                	mov    %eax,(%esi)
  800e52:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e55:	89 d8                	mov    %ebx,%eax
  800e57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5a:	5b                   	pop    %ebx
  800e5b:	5e                   	pop    %esi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	53                   	push   %ebx
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e70:	53                   	push   %ebx
  800e71:	ff 75 0c             	pushl  0xc(%ebp)
  800e74:	68 04 60 80 00       	push   $0x806004
  800e79:	e8 6b 0e 00 00       	call   801ce9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e7e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e84:	b8 02 00 00 00       	mov    $0x2,%eax
  800e89:	e8 36 ff ff ff       	call   800dc4 <nsipc>
}
  800e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea9:	b8 03 00 00 00       	mov    $0x3,%eax
  800eae:	e8 11 ff ff ff       	call   800dc4 <nsipc>
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ec3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec8:	e8 f7 fe ff ff       	call   800dc4 <nsipc>
}
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  800edc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ee1:	53                   	push   %ebx
  800ee2:	ff 75 0c             	pushl  0xc(%ebp)
  800ee5:	68 04 60 80 00       	push   $0x806004
  800eea:	e8 fa 0d 00 00       	call   801ce9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eef:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ef5:	b8 05 00 00 00       	mov    $0x5,%eax
  800efa:	e8 c5 fe ff ff       	call   800dc4 <nsipc>
}
  800eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f15:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1f:	e8 a0 fe ff ff       	call   800dc4 <nsipc>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f36:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f44:	b8 07 00 00 00       	mov    $0x7,%eax
  800f49:	e8 76 fe ff ff       	call   800dc4 <nsipc>
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 35                	js     800f89 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f54:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f59:	7f 04                	jg     800f5f <nsipc_recv+0x39>
  800f5b:	39 c6                	cmp    %eax,%esi
  800f5d:	7d 16                	jge    800f75 <nsipc_recv+0x4f>
  800f5f:	68 67 23 80 00       	push   $0x802367
  800f64:	68 2f 23 80 00       	push   $0x80232f
  800f69:	6a 62                	push   $0x62
  800f6b:	68 7c 23 80 00       	push   $0x80237c
  800f70:	e8 84 05 00 00       	call   8014f9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f75:	83 ec 04             	sub    $0x4,%esp
  800f78:	50                   	push   %eax
  800f79:	68 00 60 80 00       	push   $0x806000
  800f7e:	ff 75 0c             	pushl  0xc(%ebp)
  800f81:	e8 63 0d 00 00       	call   801ce9 <memmove>
  800f86:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f89:	89 d8                	mov    %ebx,%eax
  800f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	53                   	push   %ebx
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fa4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800faa:	7e 16                	jle    800fc2 <nsipc_send+0x30>
  800fac:	68 88 23 80 00       	push   $0x802388
  800fb1:	68 2f 23 80 00       	push   $0x80232f
  800fb6:	6a 6d                	push   $0x6d
  800fb8:	68 7c 23 80 00       	push   $0x80237c
  800fbd:	e8 37 05 00 00       	call   8014f9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	53                   	push   %ebx
  800fc6:	ff 75 0c             	pushl  0xc(%ebp)
  800fc9:	68 0c 60 80 00       	push   $0x80600c
  800fce:	e8 16 0d 00 00       	call   801ce9 <memmove>
	nsipcbuf.send.req_size = size;
  800fd3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fe1:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe6:	e8 d9 fd ff ff       	call   800dc4 <nsipc>
}
  800feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801001:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801006:	8b 45 10             	mov    0x10(%ebp),%eax
  801009:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80100e:	b8 09 00 00 00       	mov    $0x9,%eax
  801013:	e8 ac fd ff ff       	call   800dc4 <nsipc>
}
  801018:	c9                   	leave  
  801019:	c3                   	ret    

0080101a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	ff 75 08             	pushl  0x8(%ebp)
  801028:	e8 98 f3 ff ff       	call   8003c5 <fd2data>
  80102d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80102f:	83 c4 08             	add    $0x8,%esp
  801032:	68 94 23 80 00       	push   $0x802394
  801037:	53                   	push   %ebx
  801038:	e8 1a 0b 00 00       	call   801b57 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80103d:	8b 46 04             	mov    0x4(%esi),%eax
  801040:	2b 06                	sub    (%esi),%eax
  801042:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801048:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80104f:	00 00 00 
	stat->st_dev = &devpipe;
  801052:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801059:	30 80 00 
	return 0;
}
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
  801061:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	53                   	push   %ebx
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801072:	53                   	push   %ebx
  801073:	6a 00                	push   $0x0
  801075:	e8 6e f1 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80107a:	89 1c 24             	mov    %ebx,(%esp)
  80107d:	e8 43 f3 ff ff       	call   8003c5 <fd2data>
  801082:	83 c4 08             	add    $0x8,%esp
  801085:	50                   	push   %eax
  801086:	6a 00                	push   $0x0
  801088:	e8 5b f1 ff ff       	call   8001e8 <sys_page_unmap>
}
  80108d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 1c             	sub    $0x1c,%esp
  80109b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80109e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010a8:	83 ec 0c             	sub    $0xc,%esp
  8010ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ae:	e8 df 0e 00 00       	call   801f92 <pageref>
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	89 3c 24             	mov    %edi,(%esp)
  8010b8:	e8 d5 0e 00 00       	call   801f92 <pageref>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	39 c3                	cmp    %eax,%ebx
  8010c2:	0f 94 c1             	sete   %cl
  8010c5:	0f b6 c9             	movzbl %cl,%ecx
  8010c8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010cb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010d1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010d4:	39 ce                	cmp    %ecx,%esi
  8010d6:	74 1b                	je     8010f3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010d8:	39 c3                	cmp    %eax,%ebx
  8010da:	75 c4                	jne    8010a0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010dc:	8b 42 58             	mov    0x58(%edx),%eax
  8010df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e2:	50                   	push   %eax
  8010e3:	56                   	push   %esi
  8010e4:	68 9b 23 80 00       	push   $0x80239b
  8010e9:	e8 e4 04 00 00       	call   8015d2 <cprintf>
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	eb ad                	jmp    8010a0 <_pipeisclosed+0xe>
	}
}
  8010f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f9:	5b                   	pop    %ebx
  8010fa:	5e                   	pop    %esi
  8010fb:	5f                   	pop    %edi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 28             	sub    $0x28,%esp
  801107:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80110a:	56                   	push   %esi
  80110b:	e8 b5 f2 ff ff       	call   8003c5 <fd2data>
  801110:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	bf 00 00 00 00       	mov    $0x0,%edi
  80111a:	eb 4b                	jmp    801167 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80111c:	89 da                	mov    %ebx,%edx
  80111e:	89 f0                	mov    %esi,%eax
  801120:	e8 6d ff ff ff       	call   801092 <_pipeisclosed>
  801125:	85 c0                	test   %eax,%eax
  801127:	75 48                	jne    801171 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801129:	e8 16 f0 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80112e:	8b 43 04             	mov    0x4(%ebx),%eax
  801131:	8b 0b                	mov    (%ebx),%ecx
  801133:	8d 51 20             	lea    0x20(%ecx),%edx
  801136:	39 d0                	cmp    %edx,%eax
  801138:	73 e2                	jae    80111c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801141:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801144:	89 c2                	mov    %eax,%edx
  801146:	c1 fa 1f             	sar    $0x1f,%edx
  801149:	89 d1                	mov    %edx,%ecx
  80114b:	c1 e9 1b             	shr    $0x1b,%ecx
  80114e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801151:	83 e2 1f             	and    $0x1f,%edx
  801154:	29 ca                	sub    %ecx,%edx
  801156:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80115a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80115e:	83 c0 01             	add    $0x1,%eax
  801161:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801164:	83 c7 01             	add    $0x1,%edi
  801167:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80116a:	75 c2                	jne    80112e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80116c:	8b 45 10             	mov    0x10(%ebp),%eax
  80116f:	eb 05                	jmp    801176 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 18             	sub    $0x18,%esp
  801187:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80118a:	57                   	push   %edi
  80118b:	e8 35 f2 ff ff       	call   8003c5 <fd2data>
  801190:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119a:	eb 3d                	jmp    8011d9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80119c:	85 db                	test   %ebx,%ebx
  80119e:	74 04                	je     8011a4 <devpipe_read+0x26>
				return i;
  8011a0:	89 d8                	mov    %ebx,%eax
  8011a2:	eb 44                	jmp    8011e8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011a4:	89 f2                	mov    %esi,%edx
  8011a6:	89 f8                	mov    %edi,%eax
  8011a8:	e8 e5 fe ff ff       	call   801092 <_pipeisclosed>
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	75 32                	jne    8011e3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011b1:	e8 8e ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b6:	8b 06                	mov    (%esi),%eax
  8011b8:	3b 46 04             	cmp    0x4(%esi),%eax
  8011bb:	74 df                	je     80119c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011bd:	99                   	cltd   
  8011be:	c1 ea 1b             	shr    $0x1b,%edx
  8011c1:	01 d0                	add    %edx,%eax
  8011c3:	83 e0 1f             	and    $0x1f,%eax
  8011c6:	29 d0                	sub    %edx,%eax
  8011c8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011d3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d6:	83 c3 01             	add    $0x1,%ebx
  8011d9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011dc:	75 d8                	jne    8011b6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011de:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e1:	eb 05                	jmp    8011e8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	e8 db f1 ff ff       	call   8003dc <fd_alloc>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	89 c2                	mov    %eax,%edx
  801206:	85 c0                	test   %eax,%eax
  801208:	0f 88 2c 01 00 00    	js     80133a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	68 07 04 00 00       	push   $0x407
  801216:	ff 75 f4             	pushl  -0xc(%ebp)
  801219:	6a 00                	push   $0x0
  80121b:	e8 43 ef ff ff       	call   800163 <sys_page_alloc>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	89 c2                	mov    %eax,%edx
  801225:	85 c0                	test   %eax,%eax
  801227:	0f 88 0d 01 00 00    	js     80133a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801233:	50                   	push   %eax
  801234:	e8 a3 f1 ff ff       	call   8003dc <fd_alloc>
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	0f 88 e2 00 00 00    	js     801328 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	68 07 04 00 00       	push   $0x407
  80124e:	ff 75 f0             	pushl  -0x10(%ebp)
  801251:	6a 00                	push   $0x0
  801253:	e8 0b ef ff ff       	call   800163 <sys_page_alloc>
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	0f 88 c3 00 00 00    	js     801328 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801265:	83 ec 0c             	sub    $0xc,%esp
  801268:	ff 75 f4             	pushl  -0xc(%ebp)
  80126b:	e8 55 f1 ff ff       	call   8003c5 <fd2data>
  801270:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801272:	83 c4 0c             	add    $0xc,%esp
  801275:	68 07 04 00 00       	push   $0x407
  80127a:	50                   	push   %eax
  80127b:	6a 00                	push   $0x0
  80127d:	e8 e1 ee ff ff       	call   800163 <sys_page_alloc>
  801282:	89 c3                	mov    %eax,%ebx
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	0f 88 89 00 00 00    	js     801318 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	ff 75 f0             	pushl  -0x10(%ebp)
  801295:	e8 2b f1 ff ff       	call   8003c5 <fd2data>
  80129a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a1:	50                   	push   %eax
  8012a2:	6a 00                	push   $0x0
  8012a4:	56                   	push   %esi
  8012a5:	6a 00                	push   $0x0
  8012a7:	e8 fa ee ff ff       	call   8001a6 <sys_page_map>
  8012ac:	89 c3                	mov    %eax,%ebx
  8012ae:	83 c4 20             	add    $0x20,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 55                	js     80130a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012b5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012be:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012ca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012df:	83 ec 0c             	sub    $0xc,%esp
  8012e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e5:	e8 cb f0 ff ff       	call   8003b5 <fd2num>
  8012ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ed:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ef:	83 c4 04             	add    $0x4,%esp
  8012f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f5:	e8 bb f0 ff ff       	call   8003b5 <fd2num>
  8012fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	ba 00 00 00 00       	mov    $0x0,%edx
  801308:	eb 30                	jmp    80133a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	56                   	push   %esi
  80130e:	6a 00                	push   $0x0
  801310:	e8 d3 ee ff ff       	call   8001e8 <sys_page_unmap>
  801315:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	ff 75 f0             	pushl  -0x10(%ebp)
  80131e:	6a 00                	push   $0x0
  801320:	e8 c3 ee ff ff       	call   8001e8 <sys_page_unmap>
  801325:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	ff 75 f4             	pushl  -0xc(%ebp)
  80132e:	6a 00                	push   $0x0
  801330:	e8 b3 ee ff ff       	call   8001e8 <sys_page_unmap>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80133a:	89 d0                	mov    %edx,%eax
  80133c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801349:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	ff 75 08             	pushl  0x8(%ebp)
  801350:	e8 d6 f0 ff ff       	call   80042b <fd_lookup>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 18                	js     801374 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	ff 75 f4             	pushl  -0xc(%ebp)
  801362:	e8 5e f0 ff ff       	call   8003c5 <fd2data>
	return _pipeisclosed(fd, p);
  801367:	89 c2                	mov    %eax,%edx
  801369:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136c:	e8 21 fd ff ff       	call   801092 <_pipeisclosed>
  801371:	83 c4 10             	add    $0x10,%esp
}
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801386:	68 b3 23 80 00       	push   $0x8023b3
  80138b:	ff 75 0c             	pushl  0xc(%ebp)
  80138e:	e8 c4 07 00 00       	call   801b57 <strcpy>
	return 0;
}
  801393:	b8 00 00 00 00       	mov    $0x0,%eax
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	57                   	push   %edi
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
  8013a0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b1:	eb 2d                	jmp    8013e0 <devcons_write+0x46>
		m = n - tot;
  8013b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013b8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013c0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c3:	83 ec 04             	sub    $0x4,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	03 45 0c             	add    0xc(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	57                   	push   %edi
  8013cc:	e8 18 09 00 00       	call   801ce9 <memmove>
		sys_cputs(buf, m);
  8013d1:	83 c4 08             	add    $0x8,%esp
  8013d4:	53                   	push   %ebx
  8013d5:	57                   	push   %edi
  8013d6:	e8 cc ec ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013db:	01 de                	add    %ebx,%esi
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	89 f0                	mov    %esi,%eax
  8013e2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e5:	72 cc                	jb     8013b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5f                   	pop    %edi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013fe:	74 2a                	je     80142a <devcons_read+0x3b>
  801400:	eb 05                	jmp    801407 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801402:	e8 3d ed ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801407:	e8 b9 ec ff ff       	call   8000c5 <sys_cgetc>
  80140c:	85 c0                	test   %eax,%eax
  80140e:	74 f2                	je     801402 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801410:	85 c0                	test   %eax,%eax
  801412:	78 16                	js     80142a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801414:	83 f8 04             	cmp    $0x4,%eax
  801417:	74 0c                	je     801425 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141c:	88 02                	mov    %al,(%edx)
	return 1;
  80141e:	b8 01 00 00 00       	mov    $0x1,%eax
  801423:	eb 05                	jmp    80142a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801425:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801438:	6a 01                	push   $0x1
  80143a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	e8 64 ec ff ff       	call   8000a7 <sys_cputs>
}
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <getchar>:

int
getchar(void)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80144e:	6a 01                	push   $0x1
  801450:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	6a 00                	push   $0x0
  801456:	e8 36 f2 ff ff       	call   800691 <read>
	if (r < 0)
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 0f                	js     801471 <getchar+0x29>
		return r;
	if (r < 1)
  801462:	85 c0                	test   %eax,%eax
  801464:	7e 06                	jle    80146c <getchar+0x24>
		return -E_EOF;
	return c;
  801466:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80146a:	eb 05                	jmp    801471 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80146c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	ff 75 08             	pushl  0x8(%ebp)
  801480:	e8 a6 ef ff ff       	call   80042b <fd_lookup>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 11                	js     80149d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801495:	39 10                	cmp    %edx,(%eax)
  801497:	0f 94 c0             	sete   %al
  80149a:	0f b6 c0             	movzbl %al,%eax
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <opencons>:

int
opencons(void)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	e8 2e ef ff ff       	call   8003dc <fd_alloc>
  8014ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 3e                	js     8014f5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	68 07 04 00 00       	push   $0x407
  8014bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 9a ec ff ff       	call   800163 <sys_page_alloc>
  8014c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 23                	js     8014f5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014d2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e7:	83 ec 0c             	sub    $0xc,%esp
  8014ea:	50                   	push   %eax
  8014eb:	e8 c5 ee ff ff       	call   8003b5 <fd2num>
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
}
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	56                   	push   %esi
  8014fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801501:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801507:	e8 19 ec ff ff       	call   800125 <sys_getenvid>
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	ff 75 0c             	pushl  0xc(%ebp)
  801512:	ff 75 08             	pushl  0x8(%ebp)
  801515:	56                   	push   %esi
  801516:	50                   	push   %eax
  801517:	68 c0 23 80 00       	push   $0x8023c0
  80151c:	e8 b1 00 00 00       	call   8015d2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801521:	83 c4 18             	add    $0x18,%esp
  801524:	53                   	push   %ebx
  801525:	ff 75 10             	pushl  0x10(%ebp)
  801528:	e8 54 00 00 00       	call   801581 <vcprintf>
	cprintf("\n");
  80152d:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801534:	e8 99 00 00 00       	call   8015d2 <cprintf>
  801539:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80153c:	cc                   	int3   
  80153d:	eb fd                	jmp    80153c <_panic+0x43>

0080153f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	53                   	push   %ebx
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801549:	8b 13                	mov    (%ebx),%edx
  80154b:	8d 42 01             	lea    0x1(%edx),%eax
  80154e:	89 03                	mov    %eax,(%ebx)
  801550:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801553:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801557:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155c:	75 1a                	jne    801578 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	68 ff 00 00 00       	push   $0xff
  801566:	8d 43 08             	lea    0x8(%ebx),%eax
  801569:	50                   	push   %eax
  80156a:	e8 38 eb ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  80156f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801575:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801578:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80158a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801591:	00 00 00 
	b.cnt = 0;
  801594:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80159b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80159e:	ff 75 0c             	pushl  0xc(%ebp)
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	68 3f 15 80 00       	push   $0x80153f
  8015b0:	e8 54 01 00 00       	call   801709 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	e8 dd ea ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8015ca:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015db:	50                   	push   %eax
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	e8 9d ff ff ff       	call   801581 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	57                   	push   %edi
  8015ea:	56                   	push   %esi
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 1c             	sub    $0x1c,%esp
  8015ef:	89 c7                	mov    %eax,%edi
  8015f1:	89 d6                	mov    %edx,%esi
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801602:	bb 00 00 00 00       	mov    $0x0,%ebx
  801607:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80160a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80160d:	39 d3                	cmp    %edx,%ebx
  80160f:	72 05                	jb     801616 <printnum+0x30>
  801611:	39 45 10             	cmp    %eax,0x10(%ebp)
  801614:	77 45                	ja     80165b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	ff 75 18             	pushl  0x18(%ebp)
  80161c:	8b 45 14             	mov    0x14(%ebp),%eax
  80161f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801622:	53                   	push   %ebx
  801623:	ff 75 10             	pushl  0x10(%ebp)
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162c:	ff 75 e0             	pushl  -0x20(%ebp)
  80162f:	ff 75 dc             	pushl  -0x24(%ebp)
  801632:	ff 75 d8             	pushl  -0x28(%ebp)
  801635:	e8 96 09 00 00       	call   801fd0 <__udivdi3>
  80163a:	83 c4 18             	add    $0x18,%esp
  80163d:	52                   	push   %edx
  80163e:	50                   	push   %eax
  80163f:	89 f2                	mov    %esi,%edx
  801641:	89 f8                	mov    %edi,%eax
  801643:	e8 9e ff ff ff       	call   8015e6 <printnum>
  801648:	83 c4 20             	add    $0x20,%esp
  80164b:	eb 18                	jmp    801665 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	56                   	push   %esi
  801651:	ff 75 18             	pushl  0x18(%ebp)
  801654:	ff d7                	call   *%edi
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 03                	jmp    80165e <printnum+0x78>
  80165b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80165e:	83 eb 01             	sub    $0x1,%ebx
  801661:	85 db                	test   %ebx,%ebx
  801663:	7f e8                	jg     80164d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	56                   	push   %esi
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166f:	ff 75 e0             	pushl  -0x20(%ebp)
  801672:	ff 75 dc             	pushl  -0x24(%ebp)
  801675:	ff 75 d8             	pushl  -0x28(%ebp)
  801678:	e8 83 0a 00 00       	call   802100 <__umoddi3>
  80167d:	83 c4 14             	add    $0x14,%esp
  801680:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801687:	50                   	push   %eax
  801688:	ff d7                	call   *%edi
}
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801698:	83 fa 01             	cmp    $0x1,%edx
  80169b:	7e 0e                	jle    8016ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80169d:	8b 10                	mov    (%eax),%edx
  80169f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016a2:	89 08                	mov    %ecx,(%eax)
  8016a4:	8b 02                	mov    (%edx),%eax
  8016a6:	8b 52 04             	mov    0x4(%edx),%edx
  8016a9:	eb 22                	jmp    8016cd <getuint+0x38>
	else if (lflag)
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 10                	je     8016bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016af:	8b 10                	mov    (%eax),%edx
  8016b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b4:	89 08                	mov    %ecx,(%eax)
  8016b6:	8b 02                	mov    (%edx),%eax
  8016b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bd:	eb 0e                	jmp    8016cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016bf:	8b 10                	mov    (%eax),%edx
  8016c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016c4:	89 08                	mov    %ecx,(%eax)
  8016c6:	8b 02                	mov    (%edx),%eax
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d9:	8b 10                	mov    (%eax),%edx
  8016db:	3b 50 04             	cmp    0x4(%eax),%edx
  8016de:	73 0a                	jae    8016ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8016e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016e3:	89 08                	mov    %ecx,(%eax)
  8016e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e8:	88 02                	mov    %al,(%edx)
}
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 10             	pushl  0x10(%ebp)
  8016f9:	ff 75 0c             	pushl  0xc(%ebp)
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 05 00 00 00       	call   801709 <vprintfmt>
	va_end(ap);
}
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	57                   	push   %edi
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	83 ec 2c             	sub    $0x2c,%esp
  801712:	8b 75 08             	mov    0x8(%ebp),%esi
  801715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801718:	8b 7d 10             	mov    0x10(%ebp),%edi
  80171b:	eb 12                	jmp    80172f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80171d:	85 c0                	test   %eax,%eax
  80171f:	0f 84 89 03 00 00    	je     801aae <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	53                   	push   %ebx
  801729:	50                   	push   %eax
  80172a:	ff d6                	call   *%esi
  80172c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80172f:	83 c7 01             	add    $0x1,%edi
  801732:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801736:	83 f8 25             	cmp    $0x25,%eax
  801739:	75 e2                	jne    80171d <vprintfmt+0x14>
  80173b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80173f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801746:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80174d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	eb 07                	jmp    801762 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80175e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801762:	8d 47 01             	lea    0x1(%edi),%eax
  801765:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801768:	0f b6 07             	movzbl (%edi),%eax
  80176b:	0f b6 c8             	movzbl %al,%ecx
  80176e:	83 e8 23             	sub    $0x23,%eax
  801771:	3c 55                	cmp    $0x55,%al
  801773:	0f 87 1a 03 00 00    	ja     801a93 <vprintfmt+0x38a>
  801779:	0f b6 c0             	movzbl %al,%eax
  80177c:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801786:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80178a:	eb d6                	jmp    801762 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178f:	b8 00 00 00 00       	mov    $0x0,%eax
  801794:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801797:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80179a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80179e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017a1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017a4:	83 fa 09             	cmp    $0x9,%edx
  8017a7:	77 39                	ja     8017e2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017ac:	eb e9                	jmp    801797 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b1:	8d 48 04             	lea    0x4(%eax),%ecx
  8017b4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017b7:	8b 00                	mov    (%eax),%eax
  8017b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017bf:	eb 27                	jmp    8017e8 <vprintfmt+0xdf>
  8017c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017cb:	0f 49 c8             	cmovns %eax,%ecx
  8017ce:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d4:	eb 8c                	jmp    801762 <vprintfmt+0x59>
  8017d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017d9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017e0:	eb 80                	jmp    801762 <vprintfmt+0x59>
  8017e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017ec:	0f 89 70 ff ff ff    	jns    801762 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ff:	e9 5e ff ff ff       	jmp    801762 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801804:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801807:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80180a:	e9 53 ff ff ff       	jmp    801762 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80180f:	8b 45 14             	mov    0x14(%ebp),%eax
  801812:	8d 50 04             	lea    0x4(%eax),%edx
  801815:	89 55 14             	mov    %edx,0x14(%ebp)
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	53                   	push   %ebx
  80181c:	ff 30                	pushl  (%eax)
  80181e:	ff d6                	call   *%esi
			break;
  801820:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801823:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801826:	e9 04 ff ff ff       	jmp    80172f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80182b:	8b 45 14             	mov    0x14(%ebp),%eax
  80182e:	8d 50 04             	lea    0x4(%eax),%edx
  801831:	89 55 14             	mov    %edx,0x14(%ebp)
  801834:	8b 00                	mov    (%eax),%eax
  801836:	99                   	cltd   
  801837:	31 d0                	xor    %edx,%eax
  801839:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80183b:	83 f8 0f             	cmp    $0xf,%eax
  80183e:	7f 0b                	jg     80184b <vprintfmt+0x142>
  801840:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801847:	85 d2                	test   %edx,%edx
  801849:	75 18                	jne    801863 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80184b:	50                   	push   %eax
  80184c:	68 fb 23 80 00       	push   $0x8023fb
  801851:	53                   	push   %ebx
  801852:	56                   	push   %esi
  801853:	e8 94 fe ff ff       	call   8016ec <printfmt>
  801858:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80185e:	e9 cc fe ff ff       	jmp    80172f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801863:	52                   	push   %edx
  801864:	68 41 23 80 00       	push   $0x802341
  801869:	53                   	push   %ebx
  80186a:	56                   	push   %esi
  80186b:	e8 7c fe ff ff       	call   8016ec <printfmt>
  801870:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801876:	e9 b4 fe ff ff       	jmp    80172f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80187b:	8b 45 14             	mov    0x14(%ebp),%eax
  80187e:	8d 50 04             	lea    0x4(%eax),%edx
  801881:	89 55 14             	mov    %edx,0x14(%ebp)
  801884:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801886:	85 ff                	test   %edi,%edi
  801888:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80188d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801890:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801894:	0f 8e 94 00 00 00    	jle    80192e <vprintfmt+0x225>
  80189a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80189e:	0f 84 98 00 00 00    	je     80193c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8018aa:	57                   	push   %edi
  8018ab:	e8 86 02 00 00       	call   801b36 <strnlen>
  8018b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018b3:	29 c1                	sub    %eax,%ecx
  8018b5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018b8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018bb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018c5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c7:	eb 0f                	jmp    8018d8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018c9:	83 ec 08             	sub    $0x8,%esp
  8018cc:	53                   	push   %ebx
  8018cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d2:	83 ef 01             	sub    $0x1,%edi
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 ff                	test   %edi,%edi
  8018da:	7f ed                	jg     8018c9 <vprintfmt+0x1c0>
  8018dc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018df:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018e2:	85 c9                	test   %ecx,%ecx
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e9:	0f 49 c1             	cmovns %ecx,%eax
  8018ec:	29 c1                	sub    %eax,%ecx
  8018ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f7:	89 cb                	mov    %ecx,%ebx
  8018f9:	eb 4d                	jmp    801948 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ff:	74 1b                	je     80191c <vprintfmt+0x213>
  801901:	0f be c0             	movsbl %al,%eax
  801904:	83 e8 20             	sub    $0x20,%eax
  801907:	83 f8 5e             	cmp    $0x5e,%eax
  80190a:	76 10                	jbe    80191c <vprintfmt+0x213>
					putch('?', putdat);
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	6a 3f                	push   $0x3f
  801914:	ff 55 08             	call   *0x8(%ebp)
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	eb 0d                	jmp    801929 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	ff 75 0c             	pushl  0xc(%ebp)
  801922:	52                   	push   %edx
  801923:	ff 55 08             	call   *0x8(%ebp)
  801926:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801929:	83 eb 01             	sub    $0x1,%ebx
  80192c:	eb 1a                	jmp    801948 <vprintfmt+0x23f>
  80192e:	89 75 08             	mov    %esi,0x8(%ebp)
  801931:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801934:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801937:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193a:	eb 0c                	jmp    801948 <vprintfmt+0x23f>
  80193c:	89 75 08             	mov    %esi,0x8(%ebp)
  80193f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801942:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801945:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801948:	83 c7 01             	add    $0x1,%edi
  80194b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80194f:	0f be d0             	movsbl %al,%edx
  801952:	85 d2                	test   %edx,%edx
  801954:	74 23                	je     801979 <vprintfmt+0x270>
  801956:	85 f6                	test   %esi,%esi
  801958:	78 a1                	js     8018fb <vprintfmt+0x1f2>
  80195a:	83 ee 01             	sub    $0x1,%esi
  80195d:	79 9c                	jns    8018fb <vprintfmt+0x1f2>
  80195f:	89 df                	mov    %ebx,%edi
  801961:	8b 75 08             	mov    0x8(%ebp),%esi
  801964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801967:	eb 18                	jmp    801981 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	53                   	push   %ebx
  80196d:	6a 20                	push   $0x20
  80196f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801971:	83 ef 01             	sub    $0x1,%edi
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb 08                	jmp    801981 <vprintfmt+0x278>
  801979:	89 df                	mov    %ebx,%edi
  80197b:	8b 75 08             	mov    0x8(%ebp),%esi
  80197e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801981:	85 ff                	test   %edi,%edi
  801983:	7f e4                	jg     801969 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801985:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801988:	e9 a2 fd ff ff       	jmp    80172f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80198d:	83 fa 01             	cmp    $0x1,%edx
  801990:	7e 16                	jle    8019a8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801992:	8b 45 14             	mov    0x14(%ebp),%eax
  801995:	8d 50 08             	lea    0x8(%eax),%edx
  801998:	89 55 14             	mov    %edx,0x14(%ebp)
  80199b:	8b 50 04             	mov    0x4(%eax),%edx
  80199e:	8b 00                	mov    (%eax),%eax
  8019a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a6:	eb 32                	jmp    8019da <vprintfmt+0x2d1>
	else if (lflag)
  8019a8:	85 d2                	test   %edx,%edx
  8019aa:	74 18                	je     8019c4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8019af:	8d 50 04             	lea    0x4(%eax),%edx
  8019b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b5:	8b 00                	mov    (%eax),%eax
  8019b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ba:	89 c1                	mov    %eax,%ecx
  8019bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8019bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019c2:	eb 16                	jmp    8019da <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c7:	8d 50 04             	lea    0x4(%eax),%edx
  8019ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8019cd:	8b 00                	mov    (%eax),%eax
  8019cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d2:	89 c1                	mov    %eax,%ecx
  8019d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e9:	79 74                	jns    801a5f <vprintfmt+0x356>
				putch('-', putdat);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	53                   	push   %ebx
  8019ef:	6a 2d                	push   $0x2d
  8019f1:	ff d6                	call   *%esi
				num = -(long long) num;
  8019f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f9:	f7 d8                	neg    %eax
  8019fb:	83 d2 00             	adc    $0x0,%edx
  8019fe:	f7 da                	neg    %edx
  801a00:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a03:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a08:	eb 55                	jmp    801a5f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a0a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0d:	e8 83 fc ff ff       	call   801695 <getuint>
			base = 10;
  801a12:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a17:	eb 46                	jmp    801a5f <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a19:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1c:	e8 74 fc ff ff       	call   801695 <getuint>
			base = 8;
  801a21:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a26:	eb 37                	jmp    801a5f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	53                   	push   %ebx
  801a2c:	6a 30                	push   $0x30
  801a2e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a30:	83 c4 08             	add    $0x8,%esp
  801a33:	53                   	push   %ebx
  801a34:	6a 78                	push   $0x78
  801a36:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8d 50 04             	lea    0x4(%eax),%edx
  801a3e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a41:	8b 00                	mov    (%eax),%eax
  801a43:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a48:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a4b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a50:	eb 0d                	jmp    801a5f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a52:	8d 45 14             	lea    0x14(%ebp),%eax
  801a55:	e8 3b fc ff ff       	call   801695 <getuint>
			base = 16;
  801a5a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a66:	57                   	push   %edi
  801a67:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6a:	51                   	push   %ecx
  801a6b:	52                   	push   %edx
  801a6c:	50                   	push   %eax
  801a6d:	89 da                	mov    %ebx,%edx
  801a6f:	89 f0                	mov    %esi,%eax
  801a71:	e8 70 fb ff ff       	call   8015e6 <printnum>
			break;
  801a76:	83 c4 20             	add    $0x20,%esp
  801a79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a7c:	e9 ae fc ff ff       	jmp    80172f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	53                   	push   %ebx
  801a85:	51                   	push   %ecx
  801a86:	ff d6                	call   *%esi
			break;
  801a88:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a8e:	e9 9c fc ff ff       	jmp    80172f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	53                   	push   %ebx
  801a97:	6a 25                	push   $0x25
  801a99:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	eb 03                	jmp    801aa3 <vprintfmt+0x39a>
  801aa0:	83 ef 01             	sub    $0x1,%edi
  801aa3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa7:	75 f7                	jne    801aa0 <vprintfmt+0x397>
  801aa9:	e9 81 fc ff ff       	jmp    80172f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5f                   	pop    %edi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 18             	sub    $0x18,%esp
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ac2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801acc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	74 26                	je     801afd <vsnprintf+0x47>
  801ad7:	85 d2                	test   %edx,%edx
  801ad9:	7e 22                	jle    801afd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801adb:	ff 75 14             	pushl  0x14(%ebp)
  801ade:	ff 75 10             	pushl  0x10(%ebp)
  801ae1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ae4:	50                   	push   %eax
  801ae5:	68 cf 16 80 00       	push   $0x8016cf
  801aea:	e8 1a fc ff ff       	call   801709 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801af2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	eb 05                	jmp    801b02 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801afd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b0a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b0d:	50                   	push   %eax
  801b0e:	ff 75 10             	pushl  0x10(%ebp)
  801b11:	ff 75 0c             	pushl  0xc(%ebp)
  801b14:	ff 75 08             	pushl  0x8(%ebp)
  801b17:	e8 9a ff ff ff       	call   801ab6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
  801b29:	eb 03                	jmp    801b2e <strlen+0x10>
		n++;
  801b2b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b2e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b32:	75 f7                	jne    801b2b <strlen+0xd>
		n++;
	return n;
}
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b44:	eb 03                	jmp    801b49 <strnlen+0x13>
		n++;
  801b46:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b49:	39 c2                	cmp    %eax,%edx
  801b4b:	74 08                	je     801b55 <strnlen+0x1f>
  801b4d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b51:	75 f3                	jne    801b46 <strnlen+0x10>
  801b53:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	53                   	push   %ebx
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b61:	89 c2                	mov    %eax,%edx
  801b63:	83 c2 01             	add    $0x1,%edx
  801b66:	83 c1 01             	add    $0x1,%ecx
  801b69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b70:	84 db                	test   %bl,%bl
  801b72:	75 ef                	jne    801b63 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b74:	5b                   	pop    %ebx
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	53                   	push   %ebx
  801b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b7e:	53                   	push   %ebx
  801b7f:	e8 9a ff ff ff       	call   801b1e <strlen>
  801b84:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b87:	ff 75 0c             	pushl  0xc(%ebp)
  801b8a:	01 d8                	add    %ebx,%eax
  801b8c:	50                   	push   %eax
  801b8d:	e8 c5 ff ff ff       	call   801b57 <strcpy>
	return dst;
}
  801b92:	89 d8                	mov    %ebx,%eax
  801b94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b97:	c9                   	leave  
  801b98:	c3                   	ret    

00801b99 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	56                   	push   %esi
  801b9d:	53                   	push   %ebx
  801b9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba4:	89 f3                	mov    %esi,%ebx
  801ba6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba9:	89 f2                	mov    %esi,%edx
  801bab:	eb 0f                	jmp    801bbc <strncpy+0x23>
		*dst++ = *src;
  801bad:	83 c2 01             	add    $0x1,%edx
  801bb0:	0f b6 01             	movzbl (%ecx),%eax
  801bb3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb6:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bbc:	39 da                	cmp    %ebx,%edx
  801bbe:	75 ed                	jne    801bad <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bc0:	89 f0                	mov    %esi,%eax
  801bc2:	5b                   	pop    %ebx
  801bc3:	5e                   	pop    %esi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd1:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd6:	85 d2                	test   %edx,%edx
  801bd8:	74 21                	je     801bfb <strlcpy+0x35>
  801bda:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bde:	89 f2                	mov    %esi,%edx
  801be0:	eb 09                	jmp    801beb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801be2:	83 c2 01             	add    $0x1,%edx
  801be5:	83 c1 01             	add    $0x1,%ecx
  801be8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801beb:	39 c2                	cmp    %eax,%edx
  801bed:	74 09                	je     801bf8 <strlcpy+0x32>
  801bef:	0f b6 19             	movzbl (%ecx),%ebx
  801bf2:	84 db                	test   %bl,%bl
  801bf4:	75 ec                	jne    801be2 <strlcpy+0x1c>
  801bf6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bfb:	29 f0                	sub    %esi,%eax
}
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c07:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c0a:	eb 06                	jmp    801c12 <strcmp+0x11>
		p++, q++;
  801c0c:	83 c1 01             	add    $0x1,%ecx
  801c0f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c12:	0f b6 01             	movzbl (%ecx),%eax
  801c15:	84 c0                	test   %al,%al
  801c17:	74 04                	je     801c1d <strcmp+0x1c>
  801c19:	3a 02                	cmp    (%edx),%al
  801c1b:	74 ef                	je     801c0c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c1d:	0f b6 c0             	movzbl %al,%eax
  801c20:	0f b6 12             	movzbl (%edx),%edx
  801c23:	29 d0                	sub    %edx,%eax
}
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	53                   	push   %ebx
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c36:	eb 06                	jmp    801c3e <strncmp+0x17>
		n--, p++, q++;
  801c38:	83 c0 01             	add    $0x1,%eax
  801c3b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c3e:	39 d8                	cmp    %ebx,%eax
  801c40:	74 15                	je     801c57 <strncmp+0x30>
  801c42:	0f b6 08             	movzbl (%eax),%ecx
  801c45:	84 c9                	test   %cl,%cl
  801c47:	74 04                	je     801c4d <strncmp+0x26>
  801c49:	3a 0a                	cmp    (%edx),%cl
  801c4b:	74 eb                	je     801c38 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4d:	0f b6 00             	movzbl (%eax),%eax
  801c50:	0f b6 12             	movzbl (%edx),%edx
  801c53:	29 d0                	sub    %edx,%eax
  801c55:	eb 05                	jmp    801c5c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c57:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c5c:	5b                   	pop    %ebx
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c69:	eb 07                	jmp    801c72 <strchr+0x13>
		if (*s == c)
  801c6b:	38 ca                	cmp    %cl,%dl
  801c6d:	74 0f                	je     801c7e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c6f:	83 c0 01             	add    $0x1,%eax
  801c72:	0f b6 10             	movzbl (%eax),%edx
  801c75:	84 d2                	test   %dl,%dl
  801c77:	75 f2                	jne    801c6b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	8b 45 08             	mov    0x8(%ebp),%eax
  801c86:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c8a:	eb 03                	jmp    801c8f <strfind+0xf>
  801c8c:	83 c0 01             	add    $0x1,%eax
  801c8f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c92:	38 ca                	cmp    %cl,%dl
  801c94:	74 04                	je     801c9a <strfind+0x1a>
  801c96:	84 d2                	test   %dl,%dl
  801c98:	75 f2                	jne    801c8c <strfind+0xc>
			break;
	return (char *) s;
}
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	57                   	push   %edi
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca8:	85 c9                	test   %ecx,%ecx
  801caa:	74 36                	je     801ce2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb2:	75 28                	jne    801cdc <memset+0x40>
  801cb4:	f6 c1 03             	test   $0x3,%cl
  801cb7:	75 23                	jne    801cdc <memset+0x40>
		c &= 0xFF;
  801cb9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cbd:	89 d3                	mov    %edx,%ebx
  801cbf:	c1 e3 08             	shl    $0x8,%ebx
  801cc2:	89 d6                	mov    %edx,%esi
  801cc4:	c1 e6 18             	shl    $0x18,%esi
  801cc7:	89 d0                	mov    %edx,%eax
  801cc9:	c1 e0 10             	shl    $0x10,%eax
  801ccc:	09 f0                	or     %esi,%eax
  801cce:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	09 d0                	or     %edx,%eax
  801cd4:	c1 e9 02             	shr    $0x2,%ecx
  801cd7:	fc                   	cld    
  801cd8:	f3 ab                	rep stos %eax,%es:(%edi)
  801cda:	eb 06                	jmp    801ce2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdf:	fc                   	cld    
  801ce0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ce2:	89 f8                	mov    %edi,%eax
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	57                   	push   %edi
  801ced:	56                   	push   %esi
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf7:	39 c6                	cmp    %eax,%esi
  801cf9:	73 35                	jae    801d30 <memmove+0x47>
  801cfb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cfe:	39 d0                	cmp    %edx,%eax
  801d00:	73 2e                	jae    801d30 <memmove+0x47>
		s += n;
		d += n;
  801d02:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d05:	89 d6                	mov    %edx,%esi
  801d07:	09 fe                	or     %edi,%esi
  801d09:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d0f:	75 13                	jne    801d24 <memmove+0x3b>
  801d11:	f6 c1 03             	test   $0x3,%cl
  801d14:	75 0e                	jne    801d24 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d16:	83 ef 04             	sub    $0x4,%edi
  801d19:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d1c:	c1 e9 02             	shr    $0x2,%ecx
  801d1f:	fd                   	std    
  801d20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d22:	eb 09                	jmp    801d2d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d24:	83 ef 01             	sub    $0x1,%edi
  801d27:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d2a:	fd                   	std    
  801d2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d2d:	fc                   	cld    
  801d2e:	eb 1d                	jmp    801d4d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	09 c2                	or     %eax,%edx
  801d34:	f6 c2 03             	test   $0x3,%dl
  801d37:	75 0f                	jne    801d48 <memmove+0x5f>
  801d39:	f6 c1 03             	test   $0x3,%cl
  801d3c:	75 0a                	jne    801d48 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d3e:	c1 e9 02             	shr    $0x2,%ecx
  801d41:	89 c7                	mov    %eax,%edi
  801d43:	fc                   	cld    
  801d44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d46:	eb 05                	jmp    801d4d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d48:	89 c7                	mov    %eax,%edi
  801d4a:	fc                   	cld    
  801d4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d4d:	5e                   	pop    %esi
  801d4e:	5f                   	pop    %edi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d54:	ff 75 10             	pushl  0x10(%ebp)
  801d57:	ff 75 0c             	pushl  0xc(%ebp)
  801d5a:	ff 75 08             	pushl  0x8(%ebp)
  801d5d:	e8 87 ff ff ff       	call   801ce9 <memmove>
}
  801d62:	c9                   	leave  
  801d63:	c3                   	ret    

00801d64 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	56                   	push   %esi
  801d68:	53                   	push   %ebx
  801d69:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d74:	eb 1a                	jmp    801d90 <memcmp+0x2c>
		if (*s1 != *s2)
  801d76:	0f b6 08             	movzbl (%eax),%ecx
  801d79:	0f b6 1a             	movzbl (%edx),%ebx
  801d7c:	38 d9                	cmp    %bl,%cl
  801d7e:	74 0a                	je     801d8a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d80:	0f b6 c1             	movzbl %cl,%eax
  801d83:	0f b6 db             	movzbl %bl,%ebx
  801d86:	29 d8                	sub    %ebx,%eax
  801d88:	eb 0f                	jmp    801d99 <memcmp+0x35>
		s1++, s2++;
  801d8a:	83 c0 01             	add    $0x1,%eax
  801d8d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d90:	39 f0                	cmp    %esi,%eax
  801d92:	75 e2                	jne    801d76 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	53                   	push   %ebx
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801da4:	89 c1                	mov    %eax,%ecx
  801da6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dad:	eb 0a                	jmp    801db9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801daf:	0f b6 10             	movzbl (%eax),%edx
  801db2:	39 da                	cmp    %ebx,%edx
  801db4:	74 07                	je     801dbd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db6:	83 c0 01             	add    $0x1,%eax
  801db9:	39 c8                	cmp    %ecx,%eax
  801dbb:	72 f2                	jb     801daf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dbd:	5b                   	pop    %ebx
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcc:	eb 03                	jmp    801dd1 <strtol+0x11>
		s++;
  801dce:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd1:	0f b6 01             	movzbl (%ecx),%eax
  801dd4:	3c 20                	cmp    $0x20,%al
  801dd6:	74 f6                	je     801dce <strtol+0xe>
  801dd8:	3c 09                	cmp    $0x9,%al
  801dda:	74 f2                	je     801dce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ddc:	3c 2b                	cmp    $0x2b,%al
  801dde:	75 0a                	jne    801dea <strtol+0x2a>
		s++;
  801de0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801de3:	bf 00 00 00 00       	mov    $0x0,%edi
  801de8:	eb 11                	jmp    801dfb <strtol+0x3b>
  801dea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801def:	3c 2d                	cmp    $0x2d,%al
  801df1:	75 08                	jne    801dfb <strtol+0x3b>
		s++, neg = 1;
  801df3:	83 c1 01             	add    $0x1,%ecx
  801df6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dfb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e01:	75 15                	jne    801e18 <strtol+0x58>
  801e03:	80 39 30             	cmpb   $0x30,(%ecx)
  801e06:	75 10                	jne    801e18 <strtol+0x58>
  801e08:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e0c:	75 7c                	jne    801e8a <strtol+0xca>
		s += 2, base = 16;
  801e0e:	83 c1 02             	add    $0x2,%ecx
  801e11:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e16:	eb 16                	jmp    801e2e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e18:	85 db                	test   %ebx,%ebx
  801e1a:	75 12                	jne    801e2e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e21:	80 39 30             	cmpb   $0x30,(%ecx)
  801e24:	75 08                	jne    801e2e <strtol+0x6e>
		s++, base = 8;
  801e26:	83 c1 01             	add    $0x1,%ecx
  801e29:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e33:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e36:	0f b6 11             	movzbl (%ecx),%edx
  801e39:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e3c:	89 f3                	mov    %esi,%ebx
  801e3e:	80 fb 09             	cmp    $0x9,%bl
  801e41:	77 08                	ja     801e4b <strtol+0x8b>
			dig = *s - '0';
  801e43:	0f be d2             	movsbl %dl,%edx
  801e46:	83 ea 30             	sub    $0x30,%edx
  801e49:	eb 22                	jmp    801e6d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e4b:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e4e:	89 f3                	mov    %esi,%ebx
  801e50:	80 fb 19             	cmp    $0x19,%bl
  801e53:	77 08                	ja     801e5d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e55:	0f be d2             	movsbl %dl,%edx
  801e58:	83 ea 57             	sub    $0x57,%edx
  801e5b:	eb 10                	jmp    801e6d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e5d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e60:	89 f3                	mov    %esi,%ebx
  801e62:	80 fb 19             	cmp    $0x19,%bl
  801e65:	77 16                	ja     801e7d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e67:	0f be d2             	movsbl %dl,%edx
  801e6a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e6d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e70:	7d 0b                	jge    801e7d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e72:	83 c1 01             	add    $0x1,%ecx
  801e75:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e79:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e7b:	eb b9                	jmp    801e36 <strtol+0x76>

	if (endptr)
  801e7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e81:	74 0d                	je     801e90 <strtol+0xd0>
		*endptr = (char *) s;
  801e83:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e86:	89 0e                	mov    %ecx,(%esi)
  801e88:	eb 06                	jmp    801e90 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e8a:	85 db                	test   %ebx,%ebx
  801e8c:	74 98                	je     801e26 <strtol+0x66>
  801e8e:	eb 9e                	jmp    801e2e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e90:	89 c2                	mov    %eax,%edx
  801e92:	f7 da                	neg    %edx
  801e94:	85 ff                	test   %edi,%edi
  801e96:	0f 45 c2             	cmovne %edx,%eax
}
  801e99:	5b                   	pop    %ebx
  801e9a:	5e                   	pop    %esi
  801e9b:	5f                   	pop    %edi
  801e9c:	5d                   	pop    %ebp
  801e9d:	c3                   	ret    

00801e9e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	56                   	push   %esi
  801ea2:	53                   	push   %ebx
  801ea3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801eac:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801eae:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eb3:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	50                   	push   %eax
  801eba:	e8 54 e4 ff ff       	call   800313 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 f6                	test   %esi,%esi
  801ec4:	74 14                	je     801eda <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ec6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	78 09                	js     801ed8 <ipc_recv+0x3a>
  801ecf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ed5:	8b 52 74             	mov    0x74(%edx),%edx
  801ed8:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801eda:	85 db                	test   %ebx,%ebx
  801edc:	74 14                	je     801ef2 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ede:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 09                	js     801ef0 <ipc_recv+0x52>
  801ee7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eed:	8b 52 78             	mov    0x78(%edx),%edx
  801ef0:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 08                	js     801efe <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ef6:	a1 08 40 80 00       	mov    0x804008,%eax
  801efb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801efe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    

00801f05 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	57                   	push   %edi
  801f09:	56                   	push   %esi
  801f0a:	53                   	push   %ebx
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f17:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f19:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f1e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f21:	ff 75 14             	pushl  0x14(%ebp)
  801f24:	53                   	push   %ebx
  801f25:	56                   	push   %esi
  801f26:	57                   	push   %edi
  801f27:	e8 c4 e3 ff ff       	call   8002f0 <sys_ipc_try_send>

		if (err < 0) {
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	79 1e                	jns    801f51 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f33:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f36:	75 07                	jne    801f3f <ipc_send+0x3a>
				sys_yield();
  801f38:	e8 07 e2 ff ff       	call   800144 <sys_yield>
  801f3d:	eb e2                	jmp    801f21 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f3f:	50                   	push   %eax
  801f40:	68 e0 26 80 00       	push   $0x8026e0
  801f45:	6a 49                	push   $0x49
  801f47:	68 ed 26 80 00       	push   $0x8026ed
  801f4c:	e8 a8 f5 ff ff       	call   8014f9 <_panic>
		}

	} while (err < 0);

}
  801f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f64:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f67:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f6d:	8b 52 50             	mov    0x50(%edx),%edx
  801f70:	39 ca                	cmp    %ecx,%edx
  801f72:	75 0d                	jne    801f81 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7c:	8b 40 48             	mov    0x48(%eax),%eax
  801f7f:	eb 0f                	jmp    801f90 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f81:	83 c0 01             	add    $0x1,%eax
  801f84:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f89:	75 d9                	jne    801f64 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f98:	89 d0                	mov    %edx,%eax
  801f9a:	c1 e8 16             	shr    $0x16,%eax
  801f9d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa9:	f6 c1 01             	test   $0x1,%cl
  801fac:	74 1d                	je     801fcb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fae:	c1 ea 0c             	shr    $0xc,%edx
  801fb1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb8:	f6 c2 01             	test   $0x1,%dl
  801fbb:	74 0e                	je     801fcb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fbd:	c1 ea 0c             	shr    $0xc,%edx
  801fc0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc7:	ef 
  801fc8:	0f b7 c0             	movzwl %ax,%eax
}
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
