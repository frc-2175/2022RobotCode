extends Node

class_name Math

enum LengthUnit { Inches, Feet, Meters, Centimeters }
enum MassUnit { Pounds, Kilograms }

static func in2ft(_in):
	return _in / 12

static func in2m(_in):
	return cm2m(in2cm(_in))

static func in2cm(_in):
	return _in * 2.54

static func ft2in(ft):
	return ft * 12

static func ft2m(ft):
	return ft * 0.3048

static func m2in(m):
	return m * 39.3701

static func m2ft(m):
	return in2ft(m2in(m))

static func m2cm(m):
	return m * 100

static func cm2m(cm):
	return cm * 0.01

static func psi2Nm2(psi):
	return psi * 6895

static func kg2lb(kg):
	return kg * 2.2046

static func lb2kg(lb):
	return lb * 0.4536

static func cfm2cm3ps(cfm):
	return cfm * 471.9

static func Npcm22psi(Npcm2):
	return Npcm2 * 1.45

static func psi2Npcm2(psi):
	return psi * 0.6895

static func length2m(length: float, unit) -> float:
	match unit:
		LengthUnit.Inches:
			return in2m(length)
		LengthUnit.Feet:
			return ft2m(length)
		LengthUnit.Meters:
			return length
		LengthUnit.Centimeters:
			return cm2m(length)
		_:
			printerr("Unrecognized length unit: ", unit)
			return 0.0

static func m2length(m: float, unit) -> float:
	match unit:
		LengthUnit.Inches:
			return m2in(m)
		LengthUnit.Feet:
			return m2ft(m)
		LengthUnit.Meters:
			return m
		LengthUnit.Centimeters:
			return m2cm(m)
		_:
			printerr("Unrecognized length unit: ", unit)
			return 0.0
