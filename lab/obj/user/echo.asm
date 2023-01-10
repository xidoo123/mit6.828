
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 00 23 80 00       	push   $0x802300
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 03 23 80 00       	push   $0x802303
  80008f:	6a 01                	push   $0x1
  800091:	e8 ec 0a 00 00       	call   800b82 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 d0 0a 00 00       	call   800b82 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 50 24 80 00       	push   $0x802450
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 af 0a 00 00       	call   800b82 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 4e 04 00 00       	call   80053c <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 68 08 00 00       	call   800997 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c2 03 00 00       	call   8004fb <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ec:	89 d1                	mov    %edx,%ecx
  8004ee:	89 d3                	mov    %edx,%ebx
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
  800509:	b8 03 00 00 00       	mov    $0x3,%eax
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800519:	85 c0                	test   %eax,%eax
  80051b:	7e 17                	jle    800534 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	50                   	push   %eax
  800521:	6a 03                	push   $0x3
  800523:	68 0f 23 80 00       	push   $0x80230f
  800528:	6a 23                	push   $0x23
  80052a:	68 2c 23 80 00       	push   $0x80232c
  80052f:	e8 dc 13 00 00       	call   801910 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	b8 02 00 00 00       	mov    $0x2,%eax
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 d3                	mov    %edx,%ebx
  800550:	89 d7                	mov    %edx,%edi
  800552:	89 d6                	mov    %edx,%esi
  800554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5f                   	pop    %edi
  800559:	5d                   	pop    %ebp
  80055a:	c3                   	ret    

0080055b <sys_yield>:

void
sys_yield(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 d3                	mov    %edx,%ebx
  80056f:	89 d7                	mov    %edx,%edi
  800571:	89 d6                	mov    %edx,%esi
  800573:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800583:	be 00 00 00 00       	mov    $0x0,%esi
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800590:	8b 55 08             	mov    0x8(%ebp),%edx
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	89 f7                	mov    %esi,%edi
  800598:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80059a:	85 c0                	test   %eax,%eax
  80059c:	7e 17                	jle    8005b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	50                   	push   %eax
  8005a2:	6a 04                	push   $0x4
  8005a4:	68 0f 23 80 00       	push   $0x80230f
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 2c 23 80 00       	push   $0x80232c
  8005b0:	e8 5b 13 00 00       	call   801910 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	7e 17                	jle    8005f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	50                   	push   %eax
  8005e4:	6a 05                	push   $0x5
  8005e6:	68 0f 23 80 00       	push   $0x80230f
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 2c 23 80 00       	push   $0x80232c
  8005f2:	e8 19 13 00 00       	call   801910 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 17                	jle    800639 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	50                   	push   %eax
  800626:	6a 06                	push   $0x6
  800628:	68 0f 23 80 00       	push   $0x80230f
  80062d:	6a 23                	push   $0x23
  80062f:	68 2c 23 80 00       	push   $0x80232c
  800634:	e8 d7 12 00 00       	call   801910 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	57                   	push   %edi
  800645:	56                   	push   %esi
  800646:	53                   	push   %ebx
  800647:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	89 de                	mov    %ebx,%esi
  80065e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800660:	85 c0                	test   %eax,%eax
  800662:	7e 17                	jle    80067b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	50                   	push   %eax
  800668:	6a 08                	push   $0x8
  80066a:	68 0f 23 80 00       	push   $0x80230f
  80066f:	6a 23                	push   $0x23
  800671:	68 2c 23 80 00       	push   $0x80232c
  800676:	e8 95 12 00 00       	call   801910 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800699:	8b 55 08             	mov    0x8(%ebp),%edx
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	7e 17                	jle    8006bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	50                   	push   %eax
  8006aa:	6a 09                	push   $0x9
  8006ac:	68 0f 23 80 00       	push   $0x80230f
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 2c 23 80 00       	push   $0x80232c
  8006b8:	e8 53 12 00 00       	call   801910 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	89 de                	mov    %ebx,%esi
  8006e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	7e 17                	jle    8006ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	50                   	push   %eax
  8006ec:	6a 0a                	push   $0xa
  8006ee:	68 0f 23 80 00       	push   $0x80230f
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 2c 23 80 00       	push   $0x80232c
  8006fa:	e8 11 12 00 00       	call   801910 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80070d:	be 00 00 00 00       	mov    $0x0,%esi
  800712:	b8 0c 00 00 00       	mov    $0xc,%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800720:	8b 7d 14             	mov    0x14(%ebp),%edi
  800723:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 cb                	mov    %ecx,%ebx
  800742:	89 cf                	mov    %ecx,%edi
  800744:	89 ce                	mov    %ecx,%esi
  800746:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800748:	85 c0                	test   %eax,%eax
  80074a:	7e 17                	jle    800763 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	6a 0d                	push   $0xd
  800752:	68 0f 23 80 00       	push   $0x80230f
  800757:	6a 23                	push   $0x23
  800759:	68 2c 23 80 00       	push   $0x80232c
  80075e:	e8 ad 11 00 00       	call   801910 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	57                   	push   %edi
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800771:	ba 00 00 00 00       	mov    $0x0,%edx
  800776:	b8 0e 00 00 00       	mov    $0xe,%eax
  80077b:	89 d1                	mov    %edx,%ecx
  80077d:	89 d3                	mov    %edx,%ebx
  80077f:	89 d7                	mov    %edx,%edi
  800781:	89 d6                	mov    %edx,%esi
  800783:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5f                   	pop    %edi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	57                   	push   %edi
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800793:	bb 00 00 00 00       	mov    $0x0,%ebx
  800798:	b8 0f 00 00 00       	mov    $0xf,%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a3:	89 df                	mov    %ebx,%edi
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	7e 17                	jle    8007c4 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	50                   	push   %eax
  8007b1:	6a 0f                	push   $0xf
  8007b3:	68 0f 23 80 00       	push   $0x80230f
  8007b8:	6a 23                	push   $0x23
  8007ba:	68 2c 23 80 00       	push   $0x80232c
  8007bf:	e8 4c 11 00 00       	call   801910 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8007c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5f                   	pop    %edi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8007d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8007e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007ec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007fe:	89 c2                	mov    %eax,%edx
  800800:	c1 ea 16             	shr    $0x16,%edx
  800803:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80080a:	f6 c2 01             	test   $0x1,%dl
  80080d:	74 11                	je     800820 <fd_alloc+0x2d>
  80080f:	89 c2                	mov    %eax,%edx
  800811:	c1 ea 0c             	shr    $0xc,%edx
  800814:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80081b:	f6 c2 01             	test   $0x1,%dl
  80081e:	75 09                	jne    800829 <fd_alloc+0x36>
			*fd_store = fd;
  800820:	89 01                	mov    %eax,(%ecx)
			return 0;
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	eb 17                	jmp    800840 <fd_alloc+0x4d>
  800829:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80082e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800833:	75 c9                	jne    8007fe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800835:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80083b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800848:	83 f8 1f             	cmp    $0x1f,%eax
  80084b:	77 36                	ja     800883 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80084d:	c1 e0 0c             	shl    $0xc,%eax
  800850:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800855:	89 c2                	mov    %eax,%edx
  800857:	c1 ea 16             	shr    $0x16,%edx
  80085a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800861:	f6 c2 01             	test   $0x1,%dl
  800864:	74 24                	je     80088a <fd_lookup+0x48>
  800866:	89 c2                	mov    %eax,%edx
  800868:	c1 ea 0c             	shr    $0xc,%edx
  80086b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800872:	f6 c2 01             	test   $0x1,%dl
  800875:	74 1a                	je     800891 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	89 02                	mov    %eax,(%edx)
	return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 13                	jmp    800896 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800888:	eb 0c                	jmp    800896 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80088a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088f:	eb 05                	jmp    800896 <fd_lookup+0x54>
  800891:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	ba b8 23 80 00       	mov    $0x8023b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8008a6:	eb 13                	jmp    8008bb <dev_lookup+0x23>
  8008a8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8008ab:	39 08                	cmp    %ecx,(%eax)
  8008ad:	75 0c                	jne    8008bb <dev_lookup+0x23>
			*dev = devtab[i];
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 2e                	jmp    8008e9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008bb:	8b 02                	mov    (%edx),%eax
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	75 e7                	jne    8008a8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8008c6:	8b 40 48             	mov    0x48(%eax),%eax
  8008c9:	83 ec 04             	sub    $0x4,%esp
  8008cc:	51                   	push   %ecx
  8008cd:	50                   	push   %eax
  8008ce:	68 3c 23 80 00       	push   $0x80233c
  8008d3:	e8 11 11 00 00       	call   8019e9 <cprintf>
	*dev = 0;
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	83 ec 10             	sub    $0x10,%esp
  8008f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008fc:	50                   	push   %eax
  8008fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800903:	c1 e8 0c             	shr    $0xc,%eax
  800906:	50                   	push   %eax
  800907:	e8 36 ff ff ff       	call   800842 <fd_lookup>
  80090c:	83 c4 08             	add    $0x8,%esp
  80090f:	85 c0                	test   %eax,%eax
  800911:	78 05                	js     800918 <fd_close+0x2d>
	    || fd != fd2)
  800913:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800916:	74 0c                	je     800924 <fd_close+0x39>
		return (must_exist ? r : 0);
  800918:	84 db                	test   %bl,%bl
  80091a:	ba 00 00 00 00       	mov    $0x0,%edx
  80091f:	0f 44 c2             	cmove  %edx,%eax
  800922:	eb 41                	jmp    800965 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80092a:	50                   	push   %eax
  80092b:	ff 36                	pushl  (%esi)
  80092d:	e8 66 ff ff ff       	call   800898 <dev_lookup>
  800932:	89 c3                	mov    %eax,%ebx
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	85 c0                	test   %eax,%eax
  800939:	78 1a                	js     800955 <fd_close+0x6a>
		if (dev->dev_close)
  80093b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800941:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800946:	85 c0                	test   %eax,%eax
  800948:	74 0b                	je     800955 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	56                   	push   %esi
  80094e:	ff d0                	call   *%eax
  800950:	89 c3                	mov    %eax,%ebx
  800952:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800955:	83 ec 08             	sub    $0x8,%esp
  800958:	56                   	push   %esi
  800959:	6a 00                	push   $0x0
  80095b:	e8 9f fc ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	89 d8                	mov    %ebx,%eax
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800975:	50                   	push   %eax
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 c4 fe ff ff       	call   800842 <fd_lookup>
  80097e:	83 c4 08             	add    $0x8,%esp
  800981:	85 c0                	test   %eax,%eax
  800983:	78 10                	js     800995 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800985:	83 ec 08             	sub    $0x8,%esp
  800988:	6a 01                	push   $0x1
  80098a:	ff 75 f4             	pushl  -0xc(%ebp)
  80098d:	e8 59 ff ff ff       	call   8008eb <fd_close>
  800992:	83 c4 10             	add    $0x10,%esp
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <close_all>:

void
close_all(void)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80099e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	53                   	push   %ebx
  8009a7:	e8 c0 ff ff ff       	call   80096c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ac:	83 c3 01             	add    $0x1,%ebx
  8009af:	83 c4 10             	add    $0x10,%esp
  8009b2:	83 fb 20             	cmp    $0x20,%ebx
  8009b5:	75 ec                	jne    8009a3 <close_all+0xc>
		close(i);
}
  8009b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	83 ec 2c             	sub    $0x2c,%esp
  8009c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009cb:	50                   	push   %eax
  8009cc:	ff 75 08             	pushl  0x8(%ebp)
  8009cf:	e8 6e fe ff ff       	call   800842 <fd_lookup>
  8009d4:	83 c4 08             	add    $0x8,%esp
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	0f 88 c1 00 00 00    	js     800aa0 <dup+0xe4>
		return r;
	close(newfdnum);
  8009df:	83 ec 0c             	sub    $0xc,%esp
  8009e2:	56                   	push   %esi
  8009e3:	e8 84 ff ff ff       	call   80096c <close>

	newfd = INDEX2FD(newfdnum);
  8009e8:	89 f3                	mov    %esi,%ebx
  8009ea:	c1 e3 0c             	shl    $0xc,%ebx
  8009ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8009f3:	83 c4 04             	add    $0x4,%esp
  8009f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009f9:	e8 de fd ff ff       	call   8007dc <fd2data>
  8009fe:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800a00:	89 1c 24             	mov    %ebx,(%esp)
  800a03:	e8 d4 fd ff ff       	call   8007dc <fd2data>
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a0e:	89 f8                	mov    %edi,%eax
  800a10:	c1 e8 16             	shr    $0x16,%eax
  800a13:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a1a:	a8 01                	test   $0x1,%al
  800a1c:	74 37                	je     800a55 <dup+0x99>
  800a1e:	89 f8                	mov    %edi,%eax
  800a20:	c1 e8 0c             	shr    $0xc,%eax
  800a23:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a2a:	f6 c2 01             	test   $0x1,%dl
  800a2d:	74 26                	je     800a55 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a2f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a36:	83 ec 0c             	sub    $0xc,%esp
  800a39:	25 07 0e 00 00       	and    $0xe07,%eax
  800a3e:	50                   	push   %eax
  800a3f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a42:	6a 00                	push   $0x0
  800a44:	57                   	push   %edi
  800a45:	6a 00                	push   $0x0
  800a47:	e8 71 fb ff ff       	call   8005bd <sys_page_map>
  800a4c:	89 c7                	mov    %eax,%edi
  800a4e:	83 c4 20             	add    $0x20,%esp
  800a51:	85 c0                	test   %eax,%eax
  800a53:	78 2e                	js     800a83 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a55:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a58:	89 d0                	mov    %edx,%eax
  800a5a:	c1 e8 0c             	shr    $0xc,%eax
  800a5d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	25 07 0e 00 00       	and    $0xe07,%eax
  800a6c:	50                   	push   %eax
  800a6d:	53                   	push   %ebx
  800a6e:	6a 00                	push   $0x0
  800a70:	52                   	push   %edx
  800a71:	6a 00                	push   $0x0
  800a73:	e8 45 fb ff ff       	call   8005bd <sys_page_map>
  800a78:	89 c7                	mov    %eax,%edi
  800a7a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a7d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	79 1d                	jns    800aa0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	53                   	push   %ebx
  800a87:	6a 00                	push   $0x0
  800a89:	e8 71 fb ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a8e:	83 c4 08             	add    $0x8,%esp
  800a91:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a94:	6a 00                	push   $0x0
  800a96:	e8 64 fb ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	89 f8                	mov    %edi,%eax
}
  800aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	53                   	push   %ebx
  800aac:	83 ec 14             	sub    $0x14,%esp
  800aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab5:	50                   	push   %eax
  800ab6:	53                   	push   %ebx
  800ab7:	e8 86 fd ff ff       	call   800842 <fd_lookup>
  800abc:	83 c4 08             	add    $0x8,%esp
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 6d                	js     800b32 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acb:	50                   	push   %eax
  800acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acf:	ff 30                	pushl  (%eax)
  800ad1:	e8 c2 fd ff ff       	call   800898 <dev_lookup>
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	78 4c                	js     800b29 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800add:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ae0:	8b 42 08             	mov    0x8(%edx),%eax
  800ae3:	83 e0 03             	and    $0x3,%eax
  800ae6:	83 f8 01             	cmp    $0x1,%eax
  800ae9:	75 21                	jne    800b0c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800aeb:	a1 08 40 80 00       	mov    0x804008,%eax
  800af0:	8b 40 48             	mov    0x48(%eax),%eax
  800af3:	83 ec 04             	sub    $0x4,%esp
  800af6:	53                   	push   %ebx
  800af7:	50                   	push   %eax
  800af8:	68 7d 23 80 00       	push   $0x80237d
  800afd:	e8 e7 0e 00 00       	call   8019e9 <cprintf>
		return -E_INVAL;
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b0a:	eb 26                	jmp    800b32 <read+0x8a>
	}
	if (!dev->dev_read)
  800b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0f:	8b 40 08             	mov    0x8(%eax),%eax
  800b12:	85 c0                	test   %eax,%eax
  800b14:	74 17                	je     800b2d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b16:	83 ec 04             	sub    $0x4,%esp
  800b19:	ff 75 10             	pushl  0x10(%ebp)
  800b1c:	ff 75 0c             	pushl  0xc(%ebp)
  800b1f:	52                   	push   %edx
  800b20:	ff d0                	call   *%eax
  800b22:	89 c2                	mov    %eax,%edx
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	eb 09                	jmp    800b32 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b29:	89 c2                	mov    %eax,%edx
  800b2b:	eb 05                	jmp    800b32 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b2d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800b32:	89 d0                	mov    %edx,%eax
  800b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b45:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b4d:	eb 21                	jmp    800b70 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b4f:	83 ec 04             	sub    $0x4,%esp
  800b52:	89 f0                	mov    %esi,%eax
  800b54:	29 d8                	sub    %ebx,%eax
  800b56:	50                   	push   %eax
  800b57:	89 d8                	mov    %ebx,%eax
  800b59:	03 45 0c             	add    0xc(%ebp),%eax
  800b5c:	50                   	push   %eax
  800b5d:	57                   	push   %edi
  800b5e:	e8 45 ff ff ff       	call   800aa8 <read>
		if (m < 0)
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	85 c0                	test   %eax,%eax
  800b68:	78 10                	js     800b7a <readn+0x41>
			return m;
		if (m == 0)
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	74 0a                	je     800b78 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b6e:	01 c3                	add    %eax,%ebx
  800b70:	39 f3                	cmp    %esi,%ebx
  800b72:	72 db                	jb     800b4f <readn+0x16>
  800b74:	89 d8                	mov    %ebx,%eax
  800b76:	eb 02                	jmp    800b7a <readn+0x41>
  800b78:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	83 ec 14             	sub    $0x14,%esp
  800b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b8f:	50                   	push   %eax
  800b90:	53                   	push   %ebx
  800b91:	e8 ac fc ff ff       	call   800842 <fd_lookup>
  800b96:	83 c4 08             	add    $0x8,%esp
  800b99:	89 c2                	mov    %eax,%edx
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	78 68                	js     800c07 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba5:	50                   	push   %eax
  800ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba9:	ff 30                	pushl  (%eax)
  800bab:	e8 e8 fc ff ff       	call   800898 <dev_lookup>
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	78 47                	js     800bfe <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bbe:	75 21                	jne    800be1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800bc0:	a1 08 40 80 00       	mov    0x804008,%eax
  800bc5:	8b 40 48             	mov    0x48(%eax),%eax
  800bc8:	83 ec 04             	sub    $0x4,%esp
  800bcb:	53                   	push   %ebx
  800bcc:	50                   	push   %eax
  800bcd:	68 99 23 80 00       	push   $0x802399
  800bd2:	e8 12 0e 00 00       	call   8019e9 <cprintf>
		return -E_INVAL;
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bdf:	eb 26                	jmp    800c07 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be4:	8b 52 0c             	mov    0xc(%edx),%edx
  800be7:	85 d2                	test   %edx,%edx
  800be9:	74 17                	je     800c02 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800beb:	83 ec 04             	sub    $0x4,%esp
  800bee:	ff 75 10             	pushl  0x10(%ebp)
  800bf1:	ff 75 0c             	pushl  0xc(%ebp)
  800bf4:	50                   	push   %eax
  800bf5:	ff d2                	call   *%edx
  800bf7:	89 c2                	mov    %eax,%edx
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	eb 09                	jmp    800c07 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bfe:	89 c2                	mov    %eax,%edx
  800c00:	eb 05                	jmp    800c07 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c02:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800c07:	89 d0                	mov    %edx,%eax
  800c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <seek>:

int
seek(int fdnum, off_t offset)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c14:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c17:	50                   	push   %eax
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 22 fc ff ff       	call   800842 <fd_lookup>
  800c20:	83 c4 08             	add    $0x8,%esp
  800c23:	85 c0                	test   %eax,%eax
  800c25:	78 0e                	js     800c35 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 14             	sub    $0x14,%esp
  800c3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c44:	50                   	push   %eax
  800c45:	53                   	push   %ebx
  800c46:	e8 f7 fb ff ff       	call   800842 <fd_lookup>
  800c4b:	83 c4 08             	add    $0x8,%esp
  800c4e:	89 c2                	mov    %eax,%edx
  800c50:	85 c0                	test   %eax,%eax
  800c52:	78 65                	js     800cb9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c54:	83 ec 08             	sub    $0x8,%esp
  800c57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5a:	50                   	push   %eax
  800c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5e:	ff 30                	pushl  (%eax)
  800c60:	e8 33 fc ff ff       	call   800898 <dev_lookup>
  800c65:	83 c4 10             	add    $0x10,%esp
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	78 44                	js     800cb0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c6f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c73:	75 21                	jne    800c96 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c75:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c7a:	8b 40 48             	mov    0x48(%eax),%eax
  800c7d:	83 ec 04             	sub    $0x4,%esp
  800c80:	53                   	push   %ebx
  800c81:	50                   	push   %eax
  800c82:	68 5c 23 80 00       	push   $0x80235c
  800c87:	e8 5d 0d 00 00       	call   8019e9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c94:	eb 23                	jmp    800cb9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c99:	8b 52 18             	mov    0x18(%edx),%edx
  800c9c:	85 d2                	test   %edx,%edx
  800c9e:	74 14                	je     800cb4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800ca0:	83 ec 08             	sub    $0x8,%esp
  800ca3:	ff 75 0c             	pushl  0xc(%ebp)
  800ca6:	50                   	push   %eax
  800ca7:	ff d2                	call   *%edx
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	eb 09                	jmp    800cb9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb0:	89 c2                	mov    %eax,%edx
  800cb2:	eb 05                	jmp    800cb9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800cb4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800cb9:	89 d0                	mov    %edx,%eax
  800cbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 14             	sub    $0x14,%esp
  800cc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ccd:	50                   	push   %eax
  800cce:	ff 75 08             	pushl  0x8(%ebp)
  800cd1:	e8 6c fb ff ff       	call   800842 <fd_lookup>
  800cd6:	83 c4 08             	add    $0x8,%esp
  800cd9:	89 c2                	mov    %eax,%edx
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	78 58                	js     800d37 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cdf:	83 ec 08             	sub    $0x8,%esp
  800ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce5:	50                   	push   %eax
  800ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce9:	ff 30                	pushl  (%eax)
  800ceb:	e8 a8 fb ff ff       	call   800898 <dev_lookup>
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 37                	js     800d2e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cfe:	74 32                	je     800d32 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d00:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d03:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d0a:	00 00 00 
	stat->st_isdir = 0;
  800d0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d14:	00 00 00 
	stat->st_dev = dev;
  800d17:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d1d:	83 ec 08             	sub    $0x8,%esp
  800d20:	53                   	push   %ebx
  800d21:	ff 75 f0             	pushl  -0x10(%ebp)
  800d24:	ff 50 14             	call   *0x14(%eax)
  800d27:	89 c2                	mov    %eax,%edx
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	eb 09                	jmp    800d37 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	eb 05                	jmp    800d37 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d37:	89 d0                	mov    %edx,%eax
  800d39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	6a 00                	push   $0x0
  800d48:	ff 75 08             	pushl  0x8(%ebp)
  800d4b:	e8 d6 01 00 00       	call   800f26 <open>
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	85 c0                	test   %eax,%eax
  800d57:	78 1b                	js     800d74 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d59:	83 ec 08             	sub    $0x8,%esp
  800d5c:	ff 75 0c             	pushl  0xc(%ebp)
  800d5f:	50                   	push   %eax
  800d60:	e8 5b ff ff ff       	call   800cc0 <fstat>
  800d65:	89 c6                	mov    %eax,%esi
	close(fd);
  800d67:	89 1c 24             	mov    %ebx,(%esp)
  800d6a:	e8 fd fb ff ff       	call   80096c <close>
	return r;
  800d6f:	83 c4 10             	add    $0x10,%esp
  800d72:	89 f0                	mov    %esi,%eax
}
  800d74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	89 c6                	mov    %eax,%esi
  800d82:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d84:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d8b:	75 12                	jne    800d9f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	6a 01                	push   $0x1
  800d92:	e8 59 12 00 00       	call   801ff0 <ipc_find_env>
  800d97:	a3 00 40 80 00       	mov    %eax,0x804000
  800d9c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d9f:	6a 07                	push   $0x7
  800da1:	68 00 50 80 00       	push   $0x805000
  800da6:	56                   	push   %esi
  800da7:	ff 35 00 40 80 00    	pushl  0x804000
  800dad:	e8 ea 11 00 00       	call   801f9c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800db2:	83 c4 0c             	add    $0xc,%esp
  800db5:	6a 00                	push   $0x0
  800db7:	53                   	push   %ebx
  800db8:	6a 00                	push   $0x0
  800dba:	e8 76 11 00 00       	call   801f35 <ipc_recv>
}
  800dbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	8b 40 0c             	mov    0xc(%eax),%eax
  800dd2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dda:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  800de4:	b8 02 00 00 00       	mov    $0x2,%eax
  800de9:	e8 8d ff ff ff       	call   800d7b <fsipc>
}
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dfc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e01:	ba 00 00 00 00       	mov    $0x0,%edx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	e8 6b ff ff ff       	call   800d7b <fsipc>
}
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    

00800e12 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	53                   	push   %ebx
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800e22:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e27:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e31:	e8 45 ff ff ff       	call   800d7b <fsipc>
  800e36:	85 c0                	test   %eax,%eax
  800e38:	78 2c                	js     800e66 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e3a:	83 ec 08             	sub    $0x8,%esp
  800e3d:	68 00 50 80 00       	push   $0x805000
  800e42:	53                   	push   %ebx
  800e43:	e8 2f f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e48:	a1 80 50 80 00       	mov    0x805080,%eax
  800e4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e53:	a1 84 50 80 00       	mov    0x805084,%eax
  800e58:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	8b 52 0c             	mov    0xc(%edx),%edx
  800e7a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800e80:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e85:	50                   	push   %eax
  800e86:	ff 75 0c             	pushl  0xc(%ebp)
  800e89:	68 08 50 80 00       	push   $0x805008
  800e8e:	e8 76 f4 ff ff       	call   800309 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	b8 04 00 00 00       	mov    $0x4,%eax
  800e9d:	e8 d9 fe ff ff       	call   800d7b <fsipc>

}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	8b 40 0c             	mov    0xc(%eax),%eax
  800eb2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800eb7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ebd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec7:	e8 af fe ff ff       	call   800d7b <fsipc>
  800ecc:	89 c3                	mov    %eax,%ebx
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	78 4b                	js     800f1d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ed2:	39 c6                	cmp    %eax,%esi
  800ed4:	73 16                	jae    800eec <devfile_read+0x48>
  800ed6:	68 cc 23 80 00       	push   $0x8023cc
  800edb:	68 d3 23 80 00       	push   $0x8023d3
  800ee0:	6a 7c                	push   $0x7c
  800ee2:	68 e8 23 80 00       	push   $0x8023e8
  800ee7:	e8 24 0a 00 00       	call   801910 <_panic>
	assert(r <= PGSIZE);
  800eec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ef1:	7e 16                	jle    800f09 <devfile_read+0x65>
  800ef3:	68 f3 23 80 00       	push   $0x8023f3
  800ef8:	68 d3 23 80 00       	push   $0x8023d3
  800efd:	6a 7d                	push   $0x7d
  800eff:	68 e8 23 80 00       	push   $0x8023e8
  800f04:	e8 07 0a 00 00       	call   801910 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f09:	83 ec 04             	sub    $0x4,%esp
  800f0c:	50                   	push   %eax
  800f0d:	68 00 50 80 00       	push   $0x805000
  800f12:	ff 75 0c             	pushl  0xc(%ebp)
  800f15:	e8 ef f3 ff ff       	call   800309 <memmove>
	return r;
  800f1a:	83 c4 10             	add    $0x10,%esp
}
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	53                   	push   %ebx
  800f2a:	83 ec 20             	sub    $0x20,%esp
  800f2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f30:	53                   	push   %ebx
  800f31:	e8 08 f2 ff ff       	call   80013e <strlen>
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f3e:	7f 67                	jg     800fa7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f46:	50                   	push   %eax
  800f47:	e8 a7 f8 ff ff       	call   8007f3 <fd_alloc>
  800f4c:	83 c4 10             	add    $0x10,%esp
		return r;
  800f4f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 57                	js     800fac <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	53                   	push   %ebx
  800f59:	68 00 50 80 00       	push   $0x805000
  800f5e:	e8 14 f2 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f66:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	e8 03 fe ff ff       	call   800d7b <fsipc>
  800f78:	89 c3                	mov    %eax,%ebx
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 14                	jns    800f95 <open+0x6f>
		fd_close(fd, 0);
  800f81:	83 ec 08             	sub    $0x8,%esp
  800f84:	6a 00                	push   $0x0
  800f86:	ff 75 f4             	pushl  -0xc(%ebp)
  800f89:	e8 5d f9 ff ff       	call   8008eb <fd_close>
		return r;
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	89 da                	mov    %ebx,%edx
  800f93:	eb 17                	jmp    800fac <open+0x86>
	}

	return fd2num(fd);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9b:	e8 2c f8 ff ff       	call   8007cc <fd2num>
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	eb 05                	jmp    800fac <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800fa7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800fac:	89 d0                	mov    %edx,%eax
  800fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc3:	e8 b3 fd ff ff       	call   800d7b <fsipc>
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800fd0:	68 ff 23 80 00       	push   $0x8023ff
  800fd5:	ff 75 0c             	pushl  0xc(%ebp)
  800fd8:	e8 9a f1 ff ff       	call   800177 <strcpy>
	return 0;
}
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 10             	sub    $0x10,%esp
  800feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800fee:	53                   	push   %ebx
  800fef:	e8 35 10 00 00       	call   802029 <pageref>
  800ff4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800ff7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800ffc:	83 f8 01             	cmp    $0x1,%eax
  800fff:	75 10                	jne    801011 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	ff 73 0c             	pushl  0xc(%ebx)
  801007:	e8 c0 02 00 00       	call   8012cc <nsipc_close>
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801011:	89 d0                	mov    %edx,%eax
  801013:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80101e:	6a 00                	push   $0x0
  801020:	ff 75 10             	pushl  0x10(%ebp)
  801023:	ff 75 0c             	pushl  0xc(%ebp)
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	ff 70 0c             	pushl  0xc(%eax)
  80102c:	e8 78 03 00 00       	call   8013a9 <nsipc_send>
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801039:	6a 00                	push   $0x0
  80103b:	ff 75 10             	pushl  0x10(%ebp)
  80103e:	ff 75 0c             	pushl  0xc(%ebp)
  801041:	8b 45 08             	mov    0x8(%ebp),%eax
  801044:	ff 70 0c             	pushl  0xc(%eax)
  801047:	e8 f1 02 00 00       	call   80133d <nsipc_recv>
}
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801054:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801057:	52                   	push   %edx
  801058:	50                   	push   %eax
  801059:	e8 e4 f7 ff ff       	call   800842 <fd_lookup>
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 17                	js     80107c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80106e:	39 08                	cmp    %ecx,(%eax)
  801070:	75 05                	jne    801077 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801072:	8b 40 0c             	mov    0xc(%eax),%eax
  801075:	eb 05                	jmp    80107c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801077:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
  801086:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801088:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108b:	50                   	push   %eax
  80108c:	e8 62 f7 ff ff       	call   8007f3 <fd_alloc>
  801091:	89 c3                	mov    %eax,%ebx
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 1b                	js     8010b5 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	68 07 04 00 00       	push   $0x407
  8010a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 ce f4 ff ff       	call   80057a <sys_page_alloc>
  8010ac:	89 c3                	mov    %eax,%ebx
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	79 10                	jns    8010c5 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	56                   	push   %esi
  8010b9:	e8 0e 02 00 00       	call   8012cc <nsipc_close>
		return r;
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	89 d8                	mov    %ebx,%eax
  8010c3:	eb 24                	jmp    8010e9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8010c5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8010cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ce:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8010d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8010da:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	50                   	push   %eax
  8010e1:	e8 e6 f6 ff ff       	call   8007cc <fd2num>
  8010e6:	83 c4 10             	add    $0x10,%esp
}
  8010e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	e8 50 ff ff ff       	call   80104e <fd2sockid>
		return r;
  8010fe:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	78 1f                	js     801123 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	ff 75 10             	pushl  0x10(%ebp)
  80110a:	ff 75 0c             	pushl  0xc(%ebp)
  80110d:	50                   	push   %eax
  80110e:	e8 12 01 00 00       	call   801225 <nsipc_accept>
  801113:	83 c4 10             	add    $0x10,%esp
		return r;
  801116:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 07                	js     801123 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80111c:	e8 5d ff ff ff       	call   80107e <alloc_sockfd>
  801121:	89 c1                	mov    %eax,%ecx
}
  801123:	89 c8                	mov    %ecx,%eax
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	e8 19 ff ff ff       	call   80104e <fd2sockid>
  801135:	85 c0                	test   %eax,%eax
  801137:	78 12                	js     80114b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	ff 75 10             	pushl  0x10(%ebp)
  80113f:	ff 75 0c             	pushl  0xc(%ebp)
  801142:	50                   	push   %eax
  801143:	e8 2d 01 00 00       	call   801275 <nsipc_bind>
  801148:	83 c4 10             	add    $0x10,%esp
}
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <shutdown>:

int
shutdown(int s, int how)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	e8 f3 fe ff ff       	call   80104e <fd2sockid>
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 0f                	js     80116e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	ff 75 0c             	pushl  0xc(%ebp)
  801165:	50                   	push   %eax
  801166:	e8 3f 01 00 00       	call   8012aa <nsipc_shutdown>
  80116b:	83 c4 10             	add    $0x10,%esp
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	e8 d0 fe ff ff       	call   80104e <fd2sockid>
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 12                	js     801194 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	ff 75 10             	pushl  0x10(%ebp)
  801188:	ff 75 0c             	pushl  0xc(%ebp)
  80118b:	50                   	push   %eax
  80118c:	e8 55 01 00 00       	call   8012e6 <nsipc_connect>
  801191:	83 c4 10             	add    $0x10,%esp
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <listen>:

int
listen(int s, int backlog)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80119c:	8b 45 08             	mov    0x8(%ebp),%eax
  80119f:	e8 aa fe ff ff       	call   80104e <fd2sockid>
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 0f                	js     8011b7 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	ff 75 0c             	pushl  0xc(%ebp)
  8011ae:	50                   	push   %eax
  8011af:	e8 67 01 00 00       	call   80131b <nsipc_listen>
  8011b4:	83 c4 10             	add    $0x10,%esp
}
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011bf:	ff 75 10             	pushl  0x10(%ebp)
  8011c2:	ff 75 0c             	pushl  0xc(%ebp)
  8011c5:	ff 75 08             	pushl  0x8(%ebp)
  8011c8:	e8 3a 02 00 00       	call   801407 <nsipc_socket>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 05                	js     8011d9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8011d4:	e8 a5 fe ff ff       	call   80107e <alloc_sockfd>
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8011e4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8011eb:	75 12                	jne    8011ff <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	6a 02                	push   $0x2
  8011f2:	e8 f9 0d 00 00       	call   801ff0 <ipc_find_env>
  8011f7:	a3 04 40 80 00       	mov    %eax,0x804004
  8011fc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8011ff:	6a 07                	push   $0x7
  801201:	68 00 60 80 00       	push   $0x806000
  801206:	53                   	push   %ebx
  801207:	ff 35 04 40 80 00    	pushl  0x804004
  80120d:	e8 8a 0d 00 00       	call   801f9c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801212:	83 c4 0c             	add    $0xc,%esp
  801215:	6a 00                	push   $0x0
  801217:	6a 00                	push   $0x0
  801219:	6a 00                	push   $0x0
  80121b:	e8 15 0d 00 00       	call   801f35 <ipc_recv>
}
  801220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801223:	c9                   	leave  
  801224:	c3                   	ret    

00801225 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	56                   	push   %esi
  801229:	53                   	push   %ebx
  80122a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801235:	8b 06                	mov    (%esi),%eax
  801237:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80123c:	b8 01 00 00 00       	mov    $0x1,%eax
  801241:	e8 95 ff ff ff       	call   8011db <nsipc>
  801246:	89 c3                	mov    %eax,%ebx
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 20                	js     80126c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	ff 35 10 60 80 00    	pushl  0x806010
  801255:	68 00 60 80 00       	push   $0x806000
  80125a:	ff 75 0c             	pushl  0xc(%ebp)
  80125d:	e8 a7 f0 ff ff       	call   800309 <memmove>
		*addrlen = ret->ret_addrlen;
  801262:	a1 10 60 80 00       	mov    0x806010,%eax
  801267:	89 06                	mov    %eax,(%esi)
  801269:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801287:	53                   	push   %ebx
  801288:	ff 75 0c             	pushl  0xc(%ebp)
  80128b:	68 04 60 80 00       	push   $0x806004
  801290:	e8 74 f0 ff ff       	call   800309 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801295:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80129b:	b8 02 00 00 00       	mov    $0x2,%eax
  8012a0:	e8 36 ff ff ff       	call   8011db <nsipc>
}
  8012a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    

008012aa <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8012b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8012c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8012c5:	e8 11 ff ff ff       	call   8011db <nsipc>
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <nsipc_close>:

int
nsipc_close(int s)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8012da:	b8 04 00 00 00       	mov    $0x4,%eax
  8012df:	e8 f7 fe ff ff       	call   8011db <nsipc>
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8012f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8012f8:	53                   	push   %ebx
  8012f9:	ff 75 0c             	pushl  0xc(%ebp)
  8012fc:	68 04 60 80 00       	push   $0x806004
  801301:	e8 03 f0 ff ff       	call   800309 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801306:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80130c:	b8 05 00 00 00       	mov    $0x5,%eax
  801311:	e8 c5 fe ff ff       	call   8011db <nsipc>
}
  801316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801331:	b8 06 00 00 00       	mov    $0x6,%eax
  801336:	e8 a0 fe ff ff       	call   8011db <nsipc>
}
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80134d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801353:	8b 45 14             	mov    0x14(%ebp),%eax
  801356:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80135b:	b8 07 00 00 00       	mov    $0x7,%eax
  801360:	e8 76 fe ff ff       	call   8011db <nsipc>
  801365:	89 c3                	mov    %eax,%ebx
  801367:	85 c0                	test   %eax,%eax
  801369:	78 35                	js     8013a0 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80136b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801370:	7f 04                	jg     801376 <nsipc_recv+0x39>
  801372:	39 c6                	cmp    %eax,%esi
  801374:	7d 16                	jge    80138c <nsipc_recv+0x4f>
  801376:	68 0b 24 80 00       	push   $0x80240b
  80137b:	68 d3 23 80 00       	push   $0x8023d3
  801380:	6a 62                	push   $0x62
  801382:	68 20 24 80 00       	push   $0x802420
  801387:	e8 84 05 00 00       	call   801910 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80138c:	83 ec 04             	sub    $0x4,%esp
  80138f:	50                   	push   %eax
  801390:	68 00 60 80 00       	push   $0x806000
  801395:	ff 75 0c             	pushl  0xc(%ebp)
  801398:	e8 6c ef ff ff       	call   800309 <memmove>
  80139d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8013a0:	89 d8                	mov    %ebx,%eax
  8013a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013bb:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013c1:	7e 16                	jle    8013d9 <nsipc_send+0x30>
  8013c3:	68 2c 24 80 00       	push   $0x80242c
  8013c8:	68 d3 23 80 00       	push   $0x8023d3
  8013cd:	6a 6d                	push   $0x6d
  8013cf:	68 20 24 80 00       	push   $0x802420
  8013d4:	e8 37 05 00 00       	call   801910 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	ff 75 0c             	pushl  0xc(%ebp)
  8013e0:	68 0c 60 80 00       	push   $0x80600c
  8013e5:	e8 1f ef ff ff       	call   800309 <memmove>
	nsipcbuf.send.req_size = size;
  8013ea:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8013f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8013f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8013fd:	e8 d9 fd ff ff       	call   8011db <nsipc>
}
  801402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801415:	8b 45 0c             	mov    0xc(%ebp),%eax
  801418:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80141d:	8b 45 10             	mov    0x10(%ebp),%eax
  801420:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801425:	b8 09 00 00 00       	mov    $0x9,%eax
  80142a:	e8 ac fd ff ff       	call   8011db <nsipc>
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801439:	83 ec 0c             	sub    $0xc,%esp
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	e8 98 f3 ff ff       	call   8007dc <fd2data>
  801444:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801446:	83 c4 08             	add    $0x8,%esp
  801449:	68 38 24 80 00       	push   $0x802438
  80144e:	53                   	push   %ebx
  80144f:	e8 23 ed ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801454:	8b 46 04             	mov    0x4(%esi),%eax
  801457:	2b 06                	sub    (%esi),%eax
  801459:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80145f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801466:	00 00 00 
	stat->st_dev = &devpipe;
  801469:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801470:	30 80 00 
	return 0;
}
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
  801478:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801489:	53                   	push   %ebx
  80148a:	6a 00                	push   $0x0
  80148c:	e8 6e f1 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801491:	89 1c 24             	mov    %ebx,(%esp)
  801494:	e8 43 f3 ff ff       	call   8007dc <fd2data>
  801499:	83 c4 08             	add    $0x8,%esp
  80149c:	50                   	push   %eax
  80149d:	6a 00                	push   $0x0
  80149f:	e8 5b f1 ff ff       	call   8005ff <sys_page_unmap>
}
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 1c             	sub    $0x1c,%esp
  8014b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014b5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8014b7:	a1 08 40 80 00       	mov    0x804008,%eax
  8014bc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c5:	e8 5f 0b 00 00       	call   802029 <pageref>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	89 3c 24             	mov    %edi,(%esp)
  8014cf:	e8 55 0b 00 00       	call   802029 <pageref>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	39 c3                	cmp    %eax,%ebx
  8014d9:	0f 94 c1             	sete   %cl
  8014dc:	0f b6 c9             	movzbl %cl,%ecx
  8014df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8014e2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8014e8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8014eb:	39 ce                	cmp    %ecx,%esi
  8014ed:	74 1b                	je     80150a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8014ef:	39 c3                	cmp    %eax,%ebx
  8014f1:	75 c4                	jne    8014b7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8014f3:	8b 42 58             	mov    0x58(%edx),%eax
  8014f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f9:	50                   	push   %eax
  8014fa:	56                   	push   %esi
  8014fb:	68 3f 24 80 00       	push   $0x80243f
  801500:	e8 e4 04 00 00       	call   8019e9 <cprintf>
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	eb ad                	jmp    8014b7 <_pipeisclosed+0xe>
	}
}
  80150a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80150d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 28             	sub    $0x28,%esp
  80151e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801521:	56                   	push   %esi
  801522:	e8 b5 f2 ff ff       	call   8007dc <fd2data>
  801527:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	bf 00 00 00 00       	mov    $0x0,%edi
  801531:	eb 4b                	jmp    80157e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801533:	89 da                	mov    %ebx,%edx
  801535:	89 f0                	mov    %esi,%eax
  801537:	e8 6d ff ff ff       	call   8014a9 <_pipeisclosed>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	75 48                	jne    801588 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801540:	e8 16 f0 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801545:	8b 43 04             	mov    0x4(%ebx),%eax
  801548:	8b 0b                	mov    (%ebx),%ecx
  80154a:	8d 51 20             	lea    0x20(%ecx),%edx
  80154d:	39 d0                	cmp    %edx,%eax
  80154f:	73 e2                	jae    801533 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801551:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801554:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801558:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	c1 fa 1f             	sar    $0x1f,%edx
  801560:	89 d1                	mov    %edx,%ecx
  801562:	c1 e9 1b             	shr    $0x1b,%ecx
  801565:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801568:	83 e2 1f             	and    $0x1f,%edx
  80156b:	29 ca                	sub    %ecx,%edx
  80156d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801571:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801575:	83 c0 01             	add    $0x1,%eax
  801578:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80157b:	83 c7 01             	add    $0x1,%edi
  80157e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801581:	75 c2                	jne    801545 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801583:	8b 45 10             	mov    0x10(%ebp),%eax
  801586:	eb 05                	jmp    80158d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80158d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5f                   	pop    %edi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	57                   	push   %edi
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
  80159b:	83 ec 18             	sub    $0x18,%esp
  80159e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8015a1:	57                   	push   %edi
  8015a2:	e8 35 f2 ff ff       	call   8007dc <fd2data>
  8015a7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b1:	eb 3d                	jmp    8015f0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8015b3:	85 db                	test   %ebx,%ebx
  8015b5:	74 04                	je     8015bb <devpipe_read+0x26>
				return i;
  8015b7:	89 d8                	mov    %ebx,%eax
  8015b9:	eb 44                	jmp    8015ff <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8015bb:	89 f2                	mov    %esi,%edx
  8015bd:	89 f8                	mov    %edi,%eax
  8015bf:	e8 e5 fe ff ff       	call   8014a9 <_pipeisclosed>
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	75 32                	jne    8015fa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8015c8:	e8 8e ef ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8015cd:	8b 06                	mov    (%esi),%eax
  8015cf:	3b 46 04             	cmp    0x4(%esi),%eax
  8015d2:	74 df                	je     8015b3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8015d4:	99                   	cltd   
  8015d5:	c1 ea 1b             	shr    $0x1b,%edx
  8015d8:	01 d0                	add    %edx,%eax
  8015da:	83 e0 1f             	and    $0x1f,%eax
  8015dd:	29 d0                	sub    %edx,%eax
  8015df:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8015e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8015ea:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ed:	83 c3 01             	add    $0x1,%ebx
  8015f0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015f3:	75 d8                	jne    8015cd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8015f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f8:	eb 05                	jmp    8015ff <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8015fa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8015ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	e8 db f1 ff ff       	call   8007f3 <fd_alloc>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	85 c0                	test   %eax,%eax
  80161f:	0f 88 2c 01 00 00    	js     801751 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	68 07 04 00 00       	push   $0x407
  80162d:	ff 75 f4             	pushl  -0xc(%ebp)
  801630:	6a 00                	push   $0x0
  801632:	e8 43 ef ff ff       	call   80057a <sys_page_alloc>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	85 c0                	test   %eax,%eax
  80163e:	0f 88 0d 01 00 00    	js     801751 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	e8 a3 f1 ff ff       	call   8007f3 <fd_alloc>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	0f 88 e2 00 00 00    	js     80173f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	68 07 04 00 00       	push   $0x407
  801665:	ff 75 f0             	pushl  -0x10(%ebp)
  801668:	6a 00                	push   $0x0
  80166a:	e8 0b ef ff ff       	call   80057a <sys_page_alloc>
  80166f:	89 c3                	mov    %eax,%ebx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	0f 88 c3 00 00 00    	js     80173f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80167c:	83 ec 0c             	sub    $0xc,%esp
  80167f:	ff 75 f4             	pushl  -0xc(%ebp)
  801682:	e8 55 f1 ff ff       	call   8007dc <fd2data>
  801687:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801689:	83 c4 0c             	add    $0xc,%esp
  80168c:	68 07 04 00 00       	push   $0x407
  801691:	50                   	push   %eax
  801692:	6a 00                	push   $0x0
  801694:	e8 e1 ee ff ff       	call   80057a <sys_page_alloc>
  801699:	89 c3                	mov    %eax,%ebx
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	0f 88 89 00 00 00    	js     80172f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ac:	e8 2b f1 ff ff       	call   8007dc <fd2data>
  8016b1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8016b8:	50                   	push   %eax
  8016b9:	6a 00                	push   $0x0
  8016bb:	56                   	push   %esi
  8016bc:	6a 00                	push   $0x0
  8016be:	e8 fa ee ff ff       	call   8005bd <sys_page_map>
  8016c3:	89 c3                	mov    %eax,%ebx
  8016c5:	83 c4 20             	add    $0x20,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 55                	js     801721 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8016cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8016e1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8016fc:	e8 cb f0 ff ff       	call   8007cc <fd2num>
  801701:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801704:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801706:	83 c4 04             	add    $0x4,%esp
  801709:	ff 75 f0             	pushl  -0x10(%ebp)
  80170c:	e8 bb f0 ff ff       	call   8007cc <fd2num>
  801711:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801714:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	ba 00 00 00 00       	mov    $0x0,%edx
  80171f:	eb 30                	jmp    801751 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	56                   	push   %esi
  801725:	6a 00                	push   $0x0
  801727:	e8 d3 ee ff ff       	call   8005ff <sys_page_unmap>
  80172c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	ff 75 f0             	pushl  -0x10(%ebp)
  801735:	6a 00                	push   $0x0
  801737:	e8 c3 ee ff ff       	call   8005ff <sys_page_unmap>
  80173c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	ff 75 f4             	pushl  -0xc(%ebp)
  801745:	6a 00                	push   $0x0
  801747:	e8 b3 ee ff ff       	call   8005ff <sys_page_unmap>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 d6 f0 ff ff       	call   800842 <fd_lookup>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 18                	js     80178b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	ff 75 f4             	pushl  -0xc(%ebp)
  801779:	e8 5e f0 ff ff       	call   8007dc <fd2data>
	return _pipeisclosed(fd, p);
  80177e:	89 c2                	mov    %eax,%edx
  801780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801783:	e8 21 fd ff ff       	call   8014a9 <_pipeisclosed>
  801788:	83 c4 10             	add    $0x10,%esp
}
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80179d:	68 57 24 80 00       	push   $0x802457
  8017a2:	ff 75 0c             	pushl  0xc(%ebp)
  8017a5:	e8 cd e9 ff ff       	call   800177 <strcpy>
	return 0;
}
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	57                   	push   %edi
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017bd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8017c2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017c8:	eb 2d                	jmp    8017f7 <devcons_write+0x46>
		m = n - tot;
  8017ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017cd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8017cf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8017d2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8017d7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	53                   	push   %ebx
  8017de:	03 45 0c             	add    0xc(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	57                   	push   %edi
  8017e3:	e8 21 eb ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	53                   	push   %ebx
  8017ec:	57                   	push   %edi
  8017ed:	e8 cc ec ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017f2:	01 de                	add    %ebx,%esi
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	89 f0                	mov    %esi,%eax
  8017f9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017fc:	72 cc                	jb     8017ca <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8017fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801801:	5b                   	pop    %ebx
  801802:	5e                   	pop    %esi
  801803:	5f                   	pop    %edi
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801811:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801815:	74 2a                	je     801841 <devcons_read+0x3b>
  801817:	eb 05                	jmp    80181e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801819:	e8 3d ed ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80181e:	e8 b9 ec ff ff       	call   8004dc <sys_cgetc>
  801823:	85 c0                	test   %eax,%eax
  801825:	74 f2                	je     801819 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801827:	85 c0                	test   %eax,%eax
  801829:	78 16                	js     801841 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80182b:	83 f8 04             	cmp    $0x4,%eax
  80182e:	74 0c                	je     80183c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801830:	8b 55 0c             	mov    0xc(%ebp),%edx
  801833:	88 02                	mov    %al,(%edx)
	return 1;
  801835:	b8 01 00 00 00       	mov    $0x1,%eax
  80183a:	eb 05                	jmp    801841 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80183c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80184f:	6a 01                	push   $0x1
  801851:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801854:	50                   	push   %eax
  801855:	e8 64 ec ff ff       	call   8004be <sys_cputs>
}
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <getchar>:

int
getchar(void)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801865:	6a 01                	push   $0x1
  801867:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80186a:	50                   	push   %eax
  80186b:	6a 00                	push   $0x0
  80186d:	e8 36 f2 ff ff       	call   800aa8 <read>
	if (r < 0)
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	78 0f                	js     801888 <getchar+0x29>
		return r;
	if (r < 1)
  801879:	85 c0                	test   %eax,%eax
  80187b:	7e 06                	jle    801883 <getchar+0x24>
		return -E_EOF;
	return c;
  80187d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801881:	eb 05                	jmp    801888 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801883:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801893:	50                   	push   %eax
  801894:	ff 75 08             	pushl  0x8(%ebp)
  801897:	e8 a6 ef ff ff       	call   800842 <fd_lookup>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 11                	js     8018b4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018ac:	39 10                	cmp    %edx,(%eax)
  8018ae:	0f 94 c0             	sete   %al
  8018b1:	0f b6 c0             	movzbl %al,%eax
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <opencons>:

int
opencons(void)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8018bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bf:	50                   	push   %eax
  8018c0:	e8 2e ef ff ff       	call   8007f3 <fd_alloc>
  8018c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018c8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 3e                	js     80190c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	68 07 04 00 00       	push   $0x407
  8018d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d9:	6a 00                	push   $0x0
  8018db:	e8 9a ec ff ff       	call   80057a <sys_page_alloc>
  8018e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 23                	js     80190c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8018e9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	50                   	push   %eax
  801902:	e8 c5 ee ff ff       	call   8007cc <fd2num>
  801907:	89 c2                	mov    %eax,%edx
  801909:	83 c4 10             	add    $0x10,%esp
}
  80190c:	89 d0                	mov    %edx,%eax
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801915:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801918:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80191e:	e8 19 ec ff ff       	call   80053c <sys_getenvid>
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	ff 75 08             	pushl  0x8(%ebp)
  80192c:	56                   	push   %esi
  80192d:	50                   	push   %eax
  80192e:	68 64 24 80 00       	push   $0x802464
  801933:	e8 b1 00 00 00       	call   8019e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801938:	83 c4 18             	add    $0x18,%esp
  80193b:	53                   	push   %ebx
  80193c:	ff 75 10             	pushl  0x10(%ebp)
  80193f:	e8 54 00 00 00       	call   801998 <vcprintf>
	cprintf("\n");
  801944:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  80194b:	e8 99 00 00 00       	call   8019e9 <cprintf>
  801950:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801953:	cc                   	int3   
  801954:	eb fd                	jmp    801953 <_panic+0x43>

00801956 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	83 ec 04             	sub    $0x4,%esp
  80195d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801960:	8b 13                	mov    (%ebx),%edx
  801962:	8d 42 01             	lea    0x1(%edx),%eax
  801965:	89 03                	mov    %eax,(%ebx)
  801967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80196e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801973:	75 1a                	jne    80198f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	68 ff 00 00 00       	push   $0xff
  80197d:	8d 43 08             	lea    0x8(%ebx),%eax
  801980:	50                   	push   %eax
  801981:	e8 38 eb ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  801986:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80198c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80198f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8019a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019a8:	00 00 00 
	b.cnt = 0;
  8019ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8019b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	ff 75 08             	pushl  0x8(%ebp)
  8019bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8019c1:	50                   	push   %eax
  8019c2:	68 56 19 80 00       	push   $0x801956
  8019c7:	e8 54 01 00 00       	call   801b20 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8019cc:	83 c4 08             	add    $0x8,%esp
  8019cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8019d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8019db:	50                   	push   %eax
  8019dc:	e8 dd ea ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  8019e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8019f2:	50                   	push   %eax
  8019f3:	ff 75 08             	pushl  0x8(%ebp)
  8019f6:	e8 9d ff ff ff       	call   801998 <vcprintf>
	va_end(ap);

	return cnt;
}
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	57                   	push   %edi
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	83 ec 1c             	sub    $0x1c,%esp
  801a06:	89 c7                	mov    %eax,%edi
  801a08:	89 d6                	mov    %edx,%esi
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a13:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a16:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a19:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a1e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a21:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a24:	39 d3                	cmp    %edx,%ebx
  801a26:	72 05                	jb     801a2d <printnum+0x30>
  801a28:	39 45 10             	cmp    %eax,0x10(%ebp)
  801a2b:	77 45                	ja     801a72 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	ff 75 18             	pushl  0x18(%ebp)
  801a33:	8b 45 14             	mov    0x14(%ebp),%eax
  801a36:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801a39:	53                   	push   %ebx
  801a3a:	ff 75 10             	pushl  0x10(%ebp)
  801a3d:	83 ec 08             	sub    $0x8,%esp
  801a40:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a43:	ff 75 e0             	pushl  -0x20(%ebp)
  801a46:	ff 75 dc             	pushl  -0x24(%ebp)
  801a49:	ff 75 d8             	pushl  -0x28(%ebp)
  801a4c:	e8 1f 06 00 00       	call   802070 <__udivdi3>
  801a51:	83 c4 18             	add    $0x18,%esp
  801a54:	52                   	push   %edx
  801a55:	50                   	push   %eax
  801a56:	89 f2                	mov    %esi,%edx
  801a58:	89 f8                	mov    %edi,%eax
  801a5a:	e8 9e ff ff ff       	call   8019fd <printnum>
  801a5f:	83 c4 20             	add    $0x20,%esp
  801a62:	eb 18                	jmp    801a7c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	56                   	push   %esi
  801a68:	ff 75 18             	pushl  0x18(%ebp)
  801a6b:	ff d7                	call   *%edi
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	eb 03                	jmp    801a75 <printnum+0x78>
  801a72:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801a75:	83 eb 01             	sub    $0x1,%ebx
  801a78:	85 db                	test   %ebx,%ebx
  801a7a:	7f e8                	jg     801a64 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	56                   	push   %esi
  801a80:	83 ec 04             	sub    $0x4,%esp
  801a83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a86:	ff 75 e0             	pushl  -0x20(%ebp)
  801a89:	ff 75 dc             	pushl  -0x24(%ebp)
  801a8c:	ff 75 d8             	pushl  -0x28(%ebp)
  801a8f:	e8 0c 07 00 00       	call   8021a0 <__umoddi3>
  801a94:	83 c4 14             	add    $0x14,%esp
  801a97:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  801a9e:	50                   	push   %eax
  801a9f:	ff d7                	call   *%edi
}
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5f                   	pop    %edi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    

00801aac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801aaf:	83 fa 01             	cmp    $0x1,%edx
  801ab2:	7e 0e                	jle    801ac2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801ab4:	8b 10                	mov    (%eax),%edx
  801ab6:	8d 4a 08             	lea    0x8(%edx),%ecx
  801ab9:	89 08                	mov    %ecx,(%eax)
  801abb:	8b 02                	mov    (%edx),%eax
  801abd:	8b 52 04             	mov    0x4(%edx),%edx
  801ac0:	eb 22                	jmp    801ae4 <getuint+0x38>
	else if (lflag)
  801ac2:	85 d2                	test   %edx,%edx
  801ac4:	74 10                	je     801ad6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ac6:	8b 10                	mov    (%eax),%edx
  801ac8:	8d 4a 04             	lea    0x4(%edx),%ecx
  801acb:	89 08                	mov    %ecx,(%eax)
  801acd:	8b 02                	mov    (%edx),%eax
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	eb 0e                	jmp    801ae4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801ad6:	8b 10                	mov    (%eax),%edx
  801ad8:	8d 4a 04             	lea    0x4(%edx),%ecx
  801adb:	89 08                	mov    %ecx,(%eax)
  801add:	8b 02                	mov    (%edx),%eax
  801adf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801aec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801af0:	8b 10                	mov    (%eax),%edx
  801af2:	3b 50 04             	cmp    0x4(%eax),%edx
  801af5:	73 0a                	jae    801b01 <sprintputch+0x1b>
		*b->buf++ = ch;
  801af7:	8d 4a 01             	lea    0x1(%edx),%ecx
  801afa:	89 08                	mov    %ecx,(%eax)
  801afc:	8b 45 08             	mov    0x8(%ebp),%eax
  801aff:	88 02                	mov    %al,(%edx)
}
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b09:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b0c:	50                   	push   %eax
  801b0d:	ff 75 10             	pushl  0x10(%ebp)
  801b10:	ff 75 0c             	pushl  0xc(%ebp)
  801b13:	ff 75 08             	pushl  0x8(%ebp)
  801b16:	e8 05 00 00 00       	call   801b20 <vprintfmt>
	va_end(ap);
}
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 2c             	sub    $0x2c,%esp
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b2f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b32:	eb 12                	jmp    801b46 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b34:	85 c0                	test   %eax,%eax
  801b36:	0f 84 89 03 00 00    	je     801ec5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801b3c:	83 ec 08             	sub    $0x8,%esp
  801b3f:	53                   	push   %ebx
  801b40:	50                   	push   %eax
  801b41:	ff d6                	call   *%esi
  801b43:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b46:	83 c7 01             	add    $0x1,%edi
  801b49:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b4d:	83 f8 25             	cmp    $0x25,%eax
  801b50:	75 e2                	jne    801b34 <vprintfmt+0x14>
  801b52:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b56:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b5d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b64:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b70:	eb 07                	jmp    801b79 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b72:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801b75:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b79:	8d 47 01             	lea    0x1(%edi),%eax
  801b7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b7f:	0f b6 07             	movzbl (%edi),%eax
  801b82:	0f b6 c8             	movzbl %al,%ecx
  801b85:	83 e8 23             	sub    $0x23,%eax
  801b88:	3c 55                	cmp    $0x55,%al
  801b8a:	0f 87 1a 03 00 00    	ja     801eaa <vprintfmt+0x38a>
  801b90:	0f b6 c0             	movzbl %al,%eax
  801b93:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  801b9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801b9d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801ba1:	eb d6                	jmp    801b79 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ba3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801bae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801bb1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801bb5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801bb8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801bbb:	83 fa 09             	cmp    $0x9,%edx
  801bbe:	77 39                	ja     801bf9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801bc0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801bc3:	eb e9                	jmp    801bae <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801bc5:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc8:	8d 48 04             	lea    0x4(%eax),%ecx
  801bcb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801bce:	8b 00                	mov    (%eax),%eax
  801bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801bd6:	eb 27                	jmp    801bff <vprintfmt+0xdf>
  801bd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801be2:	0f 49 c8             	cmovns %eax,%ecx
  801be5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801beb:	eb 8c                	jmp    801b79 <vprintfmt+0x59>
  801bed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801bf0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801bf7:	eb 80                	jmp    801b79 <vprintfmt+0x59>
  801bf9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bfc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801bff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c03:	0f 89 70 ff ff ff    	jns    801b79 <vprintfmt+0x59>
				width = precision, precision = -1;
  801c09:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c0f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c16:	e9 5e ff ff ff       	jmp    801b79 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c1b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c21:	e9 53 ff ff ff       	jmp    801b79 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c26:	8b 45 14             	mov    0x14(%ebp),%eax
  801c29:	8d 50 04             	lea    0x4(%eax),%edx
  801c2c:	89 55 14             	mov    %edx,0x14(%ebp)
  801c2f:	83 ec 08             	sub    $0x8,%esp
  801c32:	53                   	push   %ebx
  801c33:	ff 30                	pushl  (%eax)
  801c35:	ff d6                	call   *%esi
			break;
  801c37:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c3d:	e9 04 ff ff ff       	jmp    801b46 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c42:	8b 45 14             	mov    0x14(%ebp),%eax
  801c45:	8d 50 04             	lea    0x4(%eax),%edx
  801c48:	89 55 14             	mov    %edx,0x14(%ebp)
  801c4b:	8b 00                	mov    (%eax),%eax
  801c4d:	99                   	cltd   
  801c4e:	31 d0                	xor    %edx,%eax
  801c50:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c52:	83 f8 0f             	cmp    $0xf,%eax
  801c55:	7f 0b                	jg     801c62 <vprintfmt+0x142>
  801c57:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801c5e:	85 d2                	test   %edx,%edx
  801c60:	75 18                	jne    801c7a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801c62:	50                   	push   %eax
  801c63:	68 9f 24 80 00       	push   $0x80249f
  801c68:	53                   	push   %ebx
  801c69:	56                   	push   %esi
  801c6a:	e8 94 fe ff ff       	call   801b03 <printfmt>
  801c6f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801c75:	e9 cc fe ff ff       	jmp    801b46 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801c7a:	52                   	push   %edx
  801c7b:	68 e5 23 80 00       	push   $0x8023e5
  801c80:	53                   	push   %ebx
  801c81:	56                   	push   %esi
  801c82:	e8 7c fe ff ff       	call   801b03 <printfmt>
  801c87:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c8d:	e9 b4 fe ff ff       	jmp    801b46 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801c92:	8b 45 14             	mov    0x14(%ebp),%eax
  801c95:	8d 50 04             	lea    0x4(%eax),%edx
  801c98:	89 55 14             	mov    %edx,0x14(%ebp)
  801c9b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801c9d:	85 ff                	test   %edi,%edi
  801c9f:	b8 98 24 80 00       	mov    $0x802498,%eax
  801ca4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ca7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801cab:	0f 8e 94 00 00 00    	jle    801d45 <vprintfmt+0x225>
  801cb1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801cb5:	0f 84 98 00 00 00    	je     801d53 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	ff 75 d0             	pushl  -0x30(%ebp)
  801cc1:	57                   	push   %edi
  801cc2:	e8 8f e4 ff ff       	call   800156 <strnlen>
  801cc7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cca:	29 c1                	sub    %eax,%ecx
  801ccc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801ccf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801cd2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801cd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cd9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801cdc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801cde:	eb 0f                	jmp    801cef <vprintfmt+0x1cf>
					putch(padc, putdat);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	53                   	push   %ebx
  801ce4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ce7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ce9:	83 ef 01             	sub    $0x1,%edi
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 ff                	test   %edi,%edi
  801cf1:	7f ed                	jg     801ce0 <vprintfmt+0x1c0>
  801cf3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801cf6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801cf9:	85 c9                	test   %ecx,%ecx
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801d00:	0f 49 c1             	cmovns %ecx,%eax
  801d03:	29 c1                	sub    %eax,%ecx
  801d05:	89 75 08             	mov    %esi,0x8(%ebp)
  801d08:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d0b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d0e:	89 cb                	mov    %ecx,%ebx
  801d10:	eb 4d                	jmp    801d5f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d12:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d16:	74 1b                	je     801d33 <vprintfmt+0x213>
  801d18:	0f be c0             	movsbl %al,%eax
  801d1b:	83 e8 20             	sub    $0x20,%eax
  801d1e:	83 f8 5e             	cmp    $0x5e,%eax
  801d21:	76 10                	jbe    801d33 <vprintfmt+0x213>
					putch('?', putdat);
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	6a 3f                	push   $0x3f
  801d2b:	ff 55 08             	call   *0x8(%ebp)
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	eb 0d                	jmp    801d40 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801d33:	83 ec 08             	sub    $0x8,%esp
  801d36:	ff 75 0c             	pushl  0xc(%ebp)
  801d39:	52                   	push   %edx
  801d3a:	ff 55 08             	call   *0x8(%ebp)
  801d3d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d40:	83 eb 01             	sub    $0x1,%ebx
  801d43:	eb 1a                	jmp    801d5f <vprintfmt+0x23f>
  801d45:	89 75 08             	mov    %esi,0x8(%ebp)
  801d48:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d4b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d4e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d51:	eb 0c                	jmp    801d5f <vprintfmt+0x23f>
  801d53:	89 75 08             	mov    %esi,0x8(%ebp)
  801d56:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d59:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d5c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d5f:	83 c7 01             	add    $0x1,%edi
  801d62:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d66:	0f be d0             	movsbl %al,%edx
  801d69:	85 d2                	test   %edx,%edx
  801d6b:	74 23                	je     801d90 <vprintfmt+0x270>
  801d6d:	85 f6                	test   %esi,%esi
  801d6f:	78 a1                	js     801d12 <vprintfmt+0x1f2>
  801d71:	83 ee 01             	sub    $0x1,%esi
  801d74:	79 9c                	jns    801d12 <vprintfmt+0x1f2>
  801d76:	89 df                	mov    %ebx,%edi
  801d78:	8b 75 08             	mov    0x8(%ebp),%esi
  801d7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d7e:	eb 18                	jmp    801d98 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	53                   	push   %ebx
  801d84:	6a 20                	push   $0x20
  801d86:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801d88:	83 ef 01             	sub    $0x1,%edi
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	eb 08                	jmp    801d98 <vprintfmt+0x278>
  801d90:	89 df                	mov    %ebx,%edi
  801d92:	8b 75 08             	mov    0x8(%ebp),%esi
  801d95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	7f e4                	jg     801d80 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d9f:	e9 a2 fd ff ff       	jmp    801b46 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801da4:	83 fa 01             	cmp    $0x1,%edx
  801da7:	7e 16                	jle    801dbf <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801da9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dac:	8d 50 08             	lea    0x8(%eax),%edx
  801daf:	89 55 14             	mov    %edx,0x14(%ebp)
  801db2:	8b 50 04             	mov    0x4(%eax),%edx
  801db5:	8b 00                	mov    (%eax),%eax
  801db7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801dbd:	eb 32                	jmp    801df1 <vprintfmt+0x2d1>
	else if (lflag)
  801dbf:	85 d2                	test   %edx,%edx
  801dc1:	74 18                	je     801ddb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801dc3:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc6:	8d 50 04             	lea    0x4(%eax),%edx
  801dc9:	89 55 14             	mov    %edx,0x14(%ebp)
  801dcc:	8b 00                	mov    (%eax),%eax
  801dce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dd1:	89 c1                	mov    %eax,%ecx
  801dd3:	c1 f9 1f             	sar    $0x1f,%ecx
  801dd6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801dd9:	eb 16                	jmp    801df1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801ddb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dde:	8d 50 04             	lea    0x4(%eax),%edx
  801de1:	89 55 14             	mov    %edx,0x14(%ebp)
  801de4:	8b 00                	mov    (%eax),%eax
  801de6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801de9:	89 c1                	mov    %eax,%ecx
  801deb:	c1 f9 1f             	sar    $0x1f,%ecx
  801dee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801df1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801df4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801df7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801dfc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e00:	79 74                	jns    801e76 <vprintfmt+0x356>
				putch('-', putdat);
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	53                   	push   %ebx
  801e06:	6a 2d                	push   $0x2d
  801e08:	ff d6                	call   *%esi
				num = -(long long) num;
  801e0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e0d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e10:	f7 d8                	neg    %eax
  801e12:	83 d2 00             	adc    $0x0,%edx
  801e15:	f7 da                	neg    %edx
  801e17:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e1a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e1f:	eb 55                	jmp    801e76 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e21:	8d 45 14             	lea    0x14(%ebp),%eax
  801e24:	e8 83 fc ff ff       	call   801aac <getuint>
			base = 10;
  801e29:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801e2e:	eb 46                	jmp    801e76 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801e30:	8d 45 14             	lea    0x14(%ebp),%eax
  801e33:	e8 74 fc ff ff       	call   801aac <getuint>
			base = 8;
  801e38:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801e3d:	eb 37                	jmp    801e76 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801e3f:	83 ec 08             	sub    $0x8,%esp
  801e42:	53                   	push   %ebx
  801e43:	6a 30                	push   $0x30
  801e45:	ff d6                	call   *%esi
			putch('x', putdat);
  801e47:	83 c4 08             	add    $0x8,%esp
  801e4a:	53                   	push   %ebx
  801e4b:	6a 78                	push   $0x78
  801e4d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801e4f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e52:	8d 50 04             	lea    0x4(%eax),%edx
  801e55:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801e58:	8b 00                	mov    (%eax),%eax
  801e5a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801e5f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801e62:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801e67:	eb 0d                	jmp    801e76 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801e69:	8d 45 14             	lea    0x14(%ebp),%eax
  801e6c:	e8 3b fc ff ff       	call   801aac <getuint>
			base = 16;
  801e71:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801e76:	83 ec 0c             	sub    $0xc,%esp
  801e79:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801e7d:	57                   	push   %edi
  801e7e:	ff 75 e0             	pushl  -0x20(%ebp)
  801e81:	51                   	push   %ecx
  801e82:	52                   	push   %edx
  801e83:	50                   	push   %eax
  801e84:	89 da                	mov    %ebx,%edx
  801e86:	89 f0                	mov    %esi,%eax
  801e88:	e8 70 fb ff ff       	call   8019fd <printnum>
			break;
  801e8d:	83 c4 20             	add    $0x20,%esp
  801e90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e93:	e9 ae fc ff ff       	jmp    801b46 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	53                   	push   %ebx
  801e9c:	51                   	push   %ecx
  801e9d:	ff d6                	call   *%esi
			break;
  801e9f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ea2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ea5:	e9 9c fc ff ff       	jmp    801b46 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801eaa:	83 ec 08             	sub    $0x8,%esp
  801ead:	53                   	push   %ebx
  801eae:	6a 25                	push   $0x25
  801eb0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	eb 03                	jmp    801eba <vprintfmt+0x39a>
  801eb7:	83 ef 01             	sub    $0x1,%edi
  801eba:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ebe:	75 f7                	jne    801eb7 <vprintfmt+0x397>
  801ec0:	e9 81 fc ff ff       	jmp    801b46 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 18             	sub    $0x18,%esp
  801ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ed9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801edc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ee0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ee3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801eea:	85 c0                	test   %eax,%eax
  801eec:	74 26                	je     801f14 <vsnprintf+0x47>
  801eee:	85 d2                	test   %edx,%edx
  801ef0:	7e 22                	jle    801f14 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ef2:	ff 75 14             	pushl  0x14(%ebp)
  801ef5:	ff 75 10             	pushl  0x10(%ebp)
  801ef8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801efb:	50                   	push   %eax
  801efc:	68 e6 1a 80 00       	push   $0x801ae6
  801f01:	e8 1a fc ff ff       	call   801b20 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f06:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f09:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	eb 05                	jmp    801f19 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f21:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f24:	50                   	push   %eax
  801f25:	ff 75 10             	pushl  0x10(%ebp)
  801f28:	ff 75 0c             	pushl  0xc(%ebp)
  801f2b:	ff 75 08             	pushl  0x8(%ebp)
  801f2e:	e8 9a ff ff ff       	call   801ecd <vsnprintf>
	va_end(ap);

	return rc;
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	56                   	push   %esi
  801f39:	53                   	push   %ebx
  801f3a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f43:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f45:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f4a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	50                   	push   %eax
  801f51:	e8 d4 e7 ff ff       	call   80072a <sys_ipc_recv>

	if (from_env_store != NULL)
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 f6                	test   %esi,%esi
  801f5b:	74 14                	je     801f71 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 09                	js     801f6f <ipc_recv+0x3a>
  801f66:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f6c:	8b 52 74             	mov    0x74(%edx),%edx
  801f6f:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	74 14                	je     801f89 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f75:	ba 00 00 00 00       	mov    $0x0,%edx
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	78 09                	js     801f87 <ipc_recv+0x52>
  801f7e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f84:	8b 52 78             	mov    0x78(%edx),%edx
  801f87:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 08                	js     801f95 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f8d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f92:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	57                   	push   %edi
  801fa0:	56                   	push   %esi
  801fa1:	53                   	push   %ebx
  801fa2:	83 ec 0c             	sub    $0xc,%esp
  801fa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fae:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fb0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fb5:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fb8:	ff 75 14             	pushl  0x14(%ebp)
  801fbb:	53                   	push   %ebx
  801fbc:	56                   	push   %esi
  801fbd:	57                   	push   %edi
  801fbe:	e8 44 e7 ff ff       	call   800707 <sys_ipc_try_send>

		if (err < 0) {
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	79 1e                	jns    801fe8 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcd:	75 07                	jne    801fd6 <ipc_send+0x3a>
				sys_yield();
  801fcf:	e8 87 e5 ff ff       	call   80055b <sys_yield>
  801fd4:	eb e2                	jmp    801fb8 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801fd6:	50                   	push   %eax
  801fd7:	68 80 27 80 00       	push   $0x802780
  801fdc:	6a 49                	push   $0x49
  801fde:	68 8d 27 80 00       	push   $0x80278d
  801fe3:	e8 28 f9 ff ff       	call   801910 <_panic>
		}

	} while (err < 0);

}
  801fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801feb:	5b                   	pop    %ebx
  801fec:	5e                   	pop    %esi
  801fed:	5f                   	pop    %edi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ffb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ffe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802004:	8b 52 50             	mov    0x50(%edx),%edx
  802007:	39 ca                	cmp    %ecx,%edx
  802009:	75 0d                	jne    802018 <ipc_find_env+0x28>
			return envs[i].env_id;
  80200b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802013:	8b 40 48             	mov    0x48(%eax),%eax
  802016:	eb 0f                	jmp    802027 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802018:	83 c0 01             	add    $0x1,%eax
  80201b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802020:	75 d9                	jne    801ffb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202f:	89 d0                	mov    %edx,%eax
  802031:	c1 e8 16             	shr    $0x16,%eax
  802034:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802040:	f6 c1 01             	test   $0x1,%cl
  802043:	74 1d                	je     802062 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802045:	c1 ea 0c             	shr    $0xc,%edx
  802048:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204f:	f6 c2 01             	test   $0x1,%dl
  802052:	74 0e                	je     802062 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802054:	c1 ea 0c             	shr    $0xc,%edx
  802057:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205e:	ef 
  80205f:	0f b7 c0             	movzwl %ax,%eax
}
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
